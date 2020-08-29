/**
Shader for 3D models
*/

#include "common.fxh"
#include "unrealpool.fxh"

struct VS_INPUT
{	
	float3 pos : POSITION;
	float4 color: COLOR0;
	float4 fog: COLOR1;
	float2 tex: TEXCOORD0;
	uint flags: BLENDINDICES; //flags are set per poly instead of as global state so no commits are necessary when changing them
};


struct PS_INPUT
{	
	float4 pos : SV_POSITION;
	centroid float4 color: COLOR0;
	centroid float4 fog: COLOR1;
	float2 tex: TEXCOORD0;
	uint flags: BLENDINDICES;
};

cbuffer Fog //227 / Rune object fog
{
	float fogStart;
	float fogDist;
	float fogDensity;
	int fogMode;
	float4 fogColor;
}


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
	PS_INPUT output = (PS_INPUT)0;

	/*
	Position
	*/
	float4 projected=mul(float4(input.pos,1),projection);
	output.pos = projected;
	
	
	output.color = unrealColor(input.color,input.flags);
	
	
	output.fog = unrealVertexFog(input.fog, input.flags);
	
	/*
	Misc
	*/
	output.tex = input.tex;
	output.flags = input.flags;
	
	//d3d vs unreal coords
	output.pos.y =  -output.pos.y;
	return output;
}



//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
PS_OUTPUT PS( PS_INPUT input)
{
	PS_OUTPUT output;
	//Initialize all textures to have no influence
	 
	float4 fog = input.fog;
	output.color= input.color;
		
	float4 diffuse = texDiffuse.SampleBias(sam,input.tex,LODBIAS);
	float4 diffusePoint = texDiffuse.SampleBias(samPoint,input.tex,LODBIAS);
	output.color*=diffuseTexture(diffuse,diffusePoint,input.flags);
	
	output.color+=fog;
	
	//227 / Rune object fogging
	if (fogMode == 0 && fogDist-fogStart>0)//Linear
		output.color = lerp(output.color,fogColor,saturate(input.pos.w/fogDist-fogStart));
	else if (fogMode > 0 && fogDensity>0)
	{
		if (fogMode == 1)//EXP
			output.color = lerp(output.color,fogColor,exp(input.pos.w/fogDensity));
		else if (fogMode == 2)//EXP2 
			output.color = lerp(output.color,fogColor,exp2(input.pos.w/pow(fogDensity, 2)));
	}
	
	//Compensate for darker HDR environments, but don't make objects lighter (get glowing white coats, etc)
	#if(CLASSIC_LIGHTING!=1)
		output.color.rgb=increaseDynamicRange_DarkenOnly(output.color.rgb,input.flags);
	#endif
	return output;
}


//--------------------------------------------------------------------------------------
technique10 Render
{
	pass Standard
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( NULL );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
		
		SetRasterizerState(rstate_Default);             
	}
}