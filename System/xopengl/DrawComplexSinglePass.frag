/*=============================================================================
	Fragmentshader for DrawComplexSurface, single pass.

	Revision history:
		* Created by Smirftsch
=============================================================================*/

// DrawComplex TexCoords Indices
const uint  IDX_DIFFUSE_COORDS     = 0u;
const uint  IDX_LIGHTMAP_COORDS    = 1u;
const uint  IDX_FOGMAP_COORDS      = 2u;
const uint  IDX_DETAIL_COORDS      = 3u;
const uint  IDX_MACRO_COORDS       = 4u;
const uint  IDX_BUMPMAP_COORDS     = 5u;
const uint  IDX_ENVIROMAP_COORDS   = 6u;
const uint  IDX_DIFFUSE_INFO       = 7u;
const uint  IDX_MACRO_INFO         = 8u;
const uint  IDX_BUMPMAP_INFO       = 9u;
const uint  IDX_X_AXIS             = 10u;
const uint  IDX_Y_AXIS             = 11u;
const uint  IDX_Z_AXIS             = 12u;
const uint  IDX_DRAWCOLOR          = 13u;
const uint  IDX_DISTANCE_FOG_COLOR = 14u;
const uint  IDX_DISTANCE_FOG_INFO  = 15u;

uniform sampler2D Texture0;	//Base Texture
uniform sampler2D Texture1;	//Lightmap
uniform sampler2D Texture2;	//Fogmap
uniform sampler2D Texture3;	//Detail Texture
uniform sampler2D Texture4;	//Macro Texture
uniform sampler2D Texture5;	//BumpMap
uniform sampler2D Texture6;	//EnvironmentMap

in vec3 vCoords;
#if EDITOR
flat in vec3 vSurfaceNormal;
#endif
#if ENGINE_VERSION==227 || BUMPMAPS
in vec4 vEyeSpacePos;
flat in mat3 vTBNMat;
#endif

in vec2 vTexCoords;
in vec2 vLightMapCoords;
in vec2 vFogMapCoords;
#if DETAILTEXTURES
in vec2 vDetailTexCoords;
#endif
#if MACROTEXTURES
in vec2 vMacroTexCoords;
#endif
#if BUMPMAPS
in vec2 vBumpTexCoords;
#endif
#if ENGINE_VERSION==227
in vec2 vEnvironmentTexCoords;
#endif

#ifdef GL_ES
layout ( location = 0 ) out vec4 FragColor;
#else
layout ( location = 0, index = 0) out vec4 FragColor;
//layout ( location = 0, index = 1) out vec4 FragColor1;
#endif

#if SHADERDRAWPARAMETERS
flat in uint vTexNum;
flat in uint vLightMapTexNum;
flat in uint vFogMapTexNum;
flat in uint vDetailTexNum;
flat in uint vMacroTexNum;
flat in uint vBumpMapTexNum;
flat in uint vEnviroMapTexNum;
flat in uint vDrawFlags;
flat in uint vTextureFormat;
flat in uint vPolyFlags;
flat in float vBaseDiffuse;
flat in float vBaseAlpha;
flat in float vParallaxScale;
flat in float vGamma;
flat in float vBumpMapSpecular;
# if EDITOR
flat in uint vHitTesting;
flat in uint vRendMap;
flat in vec4 vDrawColor;
# endif
flat in vec4 vDistanceFogColor;
flat in vec4 vDistanceFogInfo;
#else
uint vBumpMapTexNum;
float vBumpMapSpecular;
uniform vec4 TexCoords[16];
uniform uint TexNum[8];
uniform uint DrawFlags[4];
#endif

vec3 rgb2hsv(vec3 c)
{
	// some nice stuff from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#if ENGINE_VERSION==227
vec2 ParallaxMapping(in vec2 PTexCoords, in vec3 ViewDir, out float parallaxHeight) //http://sunandblackcat.com/tipFullView.php?topicid=28
{
#if !SHADERDRAWPARAMETERS
   float vParallaxScale = TexCoords[IDX_MACRO_INFO].w;
#endif

   // determine required number of layers
   const float minLayers = 10.0;
   const float maxLayers = 45.0;
   float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0, 0, 1), ViewDir)));

   // height of each layer
   float layerHeight = 1.0 / numLayers;
   // depth of current layer
   float currentLayerHeight = 0.0;
   // shift of texture coordinates for each iteration
   vec2 dtex = vParallaxScale * ViewDir.xy / ViewDir.z / numLayers;

   // current texture coordinates
   vec2 currentTextureCoords = PTexCoords;

   // depth from heightmap
   float heightFromTexture = 0.f;

# if BINDLESSTEXTURES
   if (vBumpMapTexNum > 0u)
     heightFromTexture = -texture(Textures[vBumpMapTexNum], currentTextureCoords).r;
   else heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# else
	heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# endif

   // while point is above surface
   while(heightFromTexture > currentLayerHeight)
   {
      // go to the next layer
      currentLayerHeight += layerHeight;
      // shift texture coordinates along V
      currentTextureCoords -= dtex;
      // new depth from heightmap
# if BINDLESSTEXTURES
   if (vBumpMapTexNum > 0u)
     heightFromTexture = -texture(Textures[vBumpMapTexNum], currentTextureCoords).r;
   else heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# else
	  heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# endif
   }

   ///////////////////////////////////////////////////////////
   // Start of Relief Parallax Mapping

   // decrease shift and height of layer by half
   vec2 deltaTexCoord = dtex / 2.0;
   float deltaHeight = layerHeight / 2.0;

   // return to the mid point of previous layer
   currentTextureCoords += deltaTexCoord;
   currentLayerHeight -= deltaHeight;

   // binary search to increase precision of Steep Paralax Mapping
   const int numSearches = 5;
   for(int i=0; i<numSearches; i++)
   {
      // decrease shift and height of layer by half
      deltaTexCoord /= 2.0;
      deltaHeight /= 2.0;

      // new depth from heightmap
# if BINDLESSTEXTURES
   if (vBumpMapTexNum > 0u)
     heightFromTexture = -texture(Textures[vBumpMapTexNum], currentTextureCoords).r;
   else heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# else
	  heightFromTexture = -texture(Texture5, currentTextureCoords).r;
# endif

      // shift along or agains vector V
      if(heightFromTexture > currentLayerHeight) // below the surface
      {
         currentTextureCoords -= deltaTexCoord;
         currentLayerHeight += deltaHeight;
      }
      else // above the surface
      {
         currentTextureCoords += deltaTexCoord;
         currentLayerHeight -= deltaHeight;
      }
   }

   // return results
   parallaxHeight = currentLayerHeight;
   return currentTextureCoords;
}
#endif

#if 1
void main (void)
{
	vec4 TotalColor = vec4(0.0,0.0,0.0,0.0);

#if !SHADERDRAWPARAMETERS
	uint vDrawFlags        = DrawFlags[0];
	uint vTextureFormat    = DrawFlags[1];
	uint vPolyFlags        = DrawFlags[2];
	uint vRendMap          = DrawFlags[3];
	bool bHitTesting       = bool(TexNum[7]);
	float vBaseDiffuse     = TexCoords[IDX_DIFFUSE_INFO].x;
	float vBaseAlpha       = TexCoords[IDX_DIFFUSE_INFO].z;
	float vGamma           = TexCoords[IDX_Z_AXIS].w;
	vec4 vDrawColor        = TexCoords[IDX_DRAWCOLOR];
	vBumpMapSpecular       = TexCoords[IDX_BUMPMAP_INFO].y;
	vec4 vDistanceFogColor = TexCoords[IDX_DISTANCE_FOG_COLOR];
	vec4 vDistanceFogInfo  = TexCoords[IDX_DISTANCE_FOG_INFO];
# if BINDLESSTEXTURES
   	uint vTexNum		   = TexNum[0];
	uint vLightMapTexNum   = TexNum[1];
	uint vFogMapTexNum     = TexNum[2];
	uint vDetailTexNum     = TexNum[3];
	uint vMacroTexNum      = TexNum[4];
	vBumpMapTexNum         = TexNum[5];
	uint vEnviroMapTexNum  = TexNum[6];
# endif
#else
# if EDITOR
	bool bHitTesting       = bool(vHitTesting);
# endif
#endif

#if HARDWARELIGHTS || BUMPMAPS
    int NumLights = int(LightData4[0].y);
	mat3 InFrameCoords = mat3(FrameCoords[1].xyz, FrameCoords[2].xyz, FrameCoords[3].xyz); // TransformPointBy...
#endif

//	mat3 InFrameUncoords =  mat3(FrameUncoords[1].xyz, FrameUncoords[2].xyz, FrameUncoords[3].xyz);

	vec2 texCoords = vTexCoords;

    vec4 Color;
#if BINDLESSTEXTURES
	if (vTexNum > 0u)
      Color = texture(Textures[vTexNum], texCoords);
	else Color = texture(Texture0, texCoords);
#else
    Color = texture(Texture0, texCoords);
#endif

    if (vBaseDiffuse > 0.0)
        Color *= vBaseDiffuse; // Diffuse factor.

	if (vBaseAlpha > 0.0)
		Color.a = vBaseAlpha; // Alpha.

    if (vTextureFormat == TEXF_BC5) //BC5 (GL_COMPRESSED_RG_RGTC2) compression
        Color.b = sqrt(1.0 - Color.r*Color.r + Color.g*Color.g);

	// Handle PF_Masked.
	if ( (vPolyFlags&PF_Masked) == PF_Masked )
	{
		if(Color.a < 0.5)
			discard;
		else Color.rgb /= Color.a;
	}
	else if ( (vPolyFlags&PF_AlphaBlend) == PF_AlphaBlend && Color.a < 0.01 )
		discard;

/*	if ((vPolyFlags&PF_Mirrored) == PF_Mirrored)
	{
		//add mirror code here.
	}
*/

	TotalColor=Color;


#if HARDWARELIGHTS
		float LightAdd = 0.0f;
		vec4 TotalAdd = vec4(0.0,0.0,0.0,0.0);

		for (int i=0; i < NumLights; i++)
		{
			float WorldLightRadius = LightData4[i].x;
			float LightRadius = LightData2[i].w;
			float RWorldLightRadius = WorldLightRadius*WorldLightRadius;

			vec3 InLightPos = ((LightPos[i].xyz - FrameCoords[0].xyz)*InFrameCoords); // Frame->Coords.
			float dist = distance(vCoords, InLightPos);

			if (dist < RWorldLightRadius)
			{
				// Light color
				vec3 LightColor = vec3(LightData1[i].x,LightData1[i].y,LightData1[i].z);

				float MinLight = 0.05;
				float b = WorldLightRadius / (RWorldLightRadius * MinLight);
				float attenuation = WorldLightRadius / (dist+b*dist*dist);

				//float attenuation = 0.82*(1.0-smoothstep(LightRadius,24.0*LightRadius+0.50,dist));

				TotalAdd += (vec4(LightColor,1.0) * attenuation);
			}
		}
		TotalColor *= TotalAdd;
#else
		// LightMap
		if ((vDrawFlags & DF_LightMap) == DF_LightMap)
		{
			vec4 LightColor;
# if BINDLESSTEXTURES
			if (vLightMapTexNum > 0u)
                LightColor = texture(Textures[vLightMapTexNum], vLightMapCoords);
			else
				LightColor = texture(Texture1, vLightMapCoords);
# else
			LightColor = texture(Texture1, vLightMapCoords);
# endif
# ifdef GL_ES
			TotalColor*=vec4(LightColor.bgr,1.0);
# else
			TotalColor*=vec4(LightColor.rgb,1.0);
# endif
			TotalColor.rgb=clamp(TotalColor.rgb*2.0,0.0,1.0); //saturate.
		}

#endif

	// DetailTextures
#if DETAILTEXTURES
	float bNear = clamp(1.0-(vCoords.z/380.0),0.0,1.0);
	if (((vDrawFlags & DF_DetailTexture) == DF_DetailTexture) && bNear > 0.0)
	{
	    vec4 DetailTexColor;
# if BINDLESSTEXTURES
        if (vDetailTexNum > 0u)
          DetailTexColor = texture(Textures[vDetailTexNum], vDetailTexCoords);
		else DetailTexColor = texture(Texture3, vDetailTexCoords);
# else
		DetailTexColor = texture(Texture3, vDetailTexCoords);
# endif

		vec3 hsvDetailTex = rgb2hsv(DetailTexColor.rgb); // cool idea Han :)
		hsvDetailTex.b += (DetailTexColor.r - 0.1);
		hsvDetailTex = hsv2rgb(hsvDetailTex);
		DetailTexColor=vec4(hsvDetailTex,0.0);
		DetailTexColor = mix(vec4(1.0,1.0,1.0,1.0), DetailTexColor, bNear); //fading out.

		TotalColor.rgb*=DetailTexColor.rgb;
	}
#endif

	// MacroTextures
#if MACROTEXTURES
if ((vDrawFlags & DF_MacroTexture) == DF_MacroTexture)
{
#if ENGINE_VERSION==227

	bool UseHeightMap = ((vPolyFlags&PF_HeightMap) == PF_HeightMap);

	// ParallaxMap
    if (UseHeightMap == true)
    {
        float parallaxHeight=0.0;

        vec3 EyeDirection_tangentspace = normalize(vTBNMat * vEyeSpacePos.xyz);
        texCoords = ParallaxMapping(texCoords,EyeDirection_tangentspace,parallaxHeight);

        // get self-shadowing factor for elements of parallax
        //float shadowMultiplier = parallaxSoftShadowMultiplier(L, texCoords, parallaxHeight - 0.05);
    }
    else
    {
# endif
	vec4 MacrotexColor;
#if BINDLESSTEXTURES
		if (vMacroTexNum > 0u)
 		  MacrotexColor = texture(Textures[vMacroTexNum], vMacroTexCoords);
		else MacrotexColor = texture(Texture4, vMacroTexCoords);
# else
		MacrotexColor = texture(Texture4, vMacroTexCoords);
# endif

		if ( (vPolyFlags&PF_Masked) == PF_Masked )
        {
            if(MacrotexColor.a < 0.5)
                discard;
            else MacrotexColor.rgb /= MacrotexColor.a;
        }
        else if ( (vPolyFlags&PF_AlphaBlend) == PF_AlphaBlend && MacrotexColor.a < 0.01 )
            discard;

		vec3 hsvMacroTex = rgb2hsv(MacrotexColor.rgb);
		hsvMacroTex.b += (MacrotexColor.r - 0.1);
		hsvMacroTex = hsv2rgb(hsvMacroTex);
		MacrotexColor=vec4(hsvMacroTex,1.0);
		TotalColor*=MacrotexColor;
#if ENGINE_VERSION==227
    }
#endif
}
#endif

	// BumpMap (Normal Map)
#if BUMPMAPS
	if ((vDrawFlags & DF_BumpMap) == DF_BumpMap)
	{
		//normal from normal map
		vec3 TextureNormal;
		vec3 TextureNormal_tangentspace;
# if BINDLESSTEXTURES
        if (vBumpMapTexNum > 0u)
          TextureNormal = texture(Textures[vBumpMapTexNum], vBumpTexCoords).rgb * 2.0 - 1.0;
		else TextureNormal = texture(Texture5, vBumpTexCoords).rgb * 2.0 - 1.0;
# else
        TextureNormal = texture(Texture5, vBumpTexCoords).rgb * 2.0 - 1.0;
# endif

        TextureNormal.b = sqrt(1.0 - TextureNormal.r*TextureNormal.r + TextureNormal.g*TextureNormal.g);

        TextureNormal_tangentspace = TextureNormal;

		vec3 BumpColor;
		vec3 TotalBumpColor=vec3(0.0,0.0,0.0);
		vec3 EyeDirection_tangentspace = vTBNMat * vEyeSpacePos.xyz;

		for(int i=0; i<NumLights; ++i)
		{
			float NormalLightRadius = LightData5[i].x;
            bool bZoneNormalLight = bool(LightData5[i].y);
			float LightRadius = LightData2[i].w;
			bool bSunlight = (uint(LightData2[i].x) == LE_Sunlight);
			vec3 InLightPos = ((LightPos[i].xyz - FrameCoords[0].xyz)*InFrameCoords); // Frame->Coords.
			float dist = distance(vCoords, InLightPos);

            float MinLight = 0.05;
            float b = NormalLightRadius / (NormalLightRadius * NormalLightRadius * MinLight);
            float attenuation = NormalLightRadius / (dist+b*dist*dist);

			if ( (vPolyFlags&PF_Unlit) == PF_Unlit)
				InLightPos=vec3(1.0,1.0,1.0); //no idea whats best here. Arbitrary value based on some tests.

			if ( (NormalLightRadius == 0.0 || (dist > NormalLightRadius) || ( bZoneNormalLight && (LightData4[i].z != LightData4[i].w))) && !bSunlight)// Do not consider if not in range or in a different zone.
				continue;

			vec3 LightPosition_cameraspace = ( viewMat * vec4(InLightPos,1)).xyz;
			vec3 LightDirection_cameraspace = vEyeSpacePos.xyz - LightPosition_cameraspace;
			vec3 LightDirection_tangentspace = vTBNMat * LightDirection_cameraspace;

			vec3 LightDir = normalize(LightDirection_tangentspace);
			// Cosine of the angle between the normal and the light direction,
			// clamped above 0
			//  - light is at the vertical of the triangle -> 1
			//  - light is perpendicular to the triangle -> 0
			//  - light is behind the triangle -> 0
			float cosTheta = clamp( dot( TextureNormal_tangentspace, LightDir ), 0.0,1.0 );

			vec3 E = normalize(EyeDirection_tangentspace);
			// Direction in which the triangle reflects the light
			vec3 R = reflect(-LightDir,TextureNormal_tangentspace);
			// Cosine of the angle between the Eye vector and the Reflect vector,
			// clamped to 0
			//  - Looking into the reflection -> 1
			//  - Looking elsewhere -> < 1
			float cosAlpha = clamp( dot( E,R ), 0.0,1.0 );

			vec3 LightColor = vec3(LightData1[i].x,LightData1[i].y,LightData1[i].z);
			vec3 MaterialAmbientColor = vec3(0.1,0.1,0.1) * Color.xyz;

			if (vBumpMapSpecular > 0.0) // Specular
				TotalBumpColor +=  (MaterialAmbientColor + Color.xyz * LightColor * cosTheta * pow(cosAlpha,vBumpMapSpecular)) * attenuation;
			else
				TotalBumpColor +=  (MaterialAmbientColor + Color.xyz * LightColor * cosTheta) * attenuation;

		}
		if (TotalBumpColor.x != 0.0 || TotalBumpColor.y != 0.0 || TotalBumpColor.z != 0.0) //no light close enough.
			TotalColor*=vec4(clamp(TotalBumpColor,0.0,1.0),1.0);
	}
#endif

	// FogMap
	if ((vDrawFlags & DF_FogMap) == DF_FogMap)
	{
	    vec4 FogColor;
#if BINDLESSTEXTURES
	    if (vFogMapTexNum > 0u)
            FogColor = texture(Textures[vFogMapTexNum], vFogMapCoords);
		else
		    FogColor = texture(Texture2, vFogMapCoords);

#else
		FogColor = texture(Texture2, vFogMapCoords);
#endif

		TotalColor.rgb = TotalColor.rgb * (1.0-FogColor.a) + FogColor.rgb;
		TotalColor.a   = FogColor.a;
	}

	// EnvironmentMap
#if ENGINE_VERSION==227
	if ((vDrawFlags & DF_EnvironmentMap) == DF_EnvironmentMap)
	{
	    vec4 EnvironmentColor;
# if BINDLESSTEXTURES
        if (vEnviroMapTexNum > 0u)
          EnvironmentColor = texture(Textures[vEnviroMapTexNum], vEnvironmentTexCoords);
		else EnvironmentColor = texture(Texture6, vEnvironmentTexCoords);
# else
		EnvironmentColor = texture(Texture6, vEnvironmentTexCoords);
# endif
        if ( (vPolyFlags&PF_Masked) == PF_Masked )
        {
            if(EnvironmentColor.a < 0.5)
                discard;
            else EnvironmentColor.rgb /= EnvironmentColor.a;
        }
        else if ( (vPolyFlags&PF_AlphaBlend) == PF_AlphaBlend && EnvironmentColor.a < 0.01 )
            discard;

		TotalColor*=vec4(EnvironmentColor.rgb,1.0);
	}
#endif

	TotalColor=clamp(TotalColor,0.0,1.0); //saturate.

	// Add DistanceFog
#if ENGINE_VERSION==227
	// stijn: Very slow! Went from 135 to 155FPS on CTF-BT-CallousV3 by just disabling this branch even tho 469 doesn't do distance fog
	if (vDistanceFogInfo.w >= 0.0)
	{
	    FogParameters DistanceFogParams;
        DistanceFogParams.FogStart = vDistanceFogInfo.x;
        DistanceFogParams.FogEnd = vDistanceFogInfo.y;
        DistanceFogParams.FogDensity = vDistanceFogInfo.z;
        DistanceFogParams.FogMode = int(vDistanceFogInfo.w);

		if ( (vPolyFlags&PF_Modulated) == PF_Modulated )
			DistanceFogParams.FogColor = vec4(0.5,0.5,0.5,0.0);
		else if ( (vPolyFlags&PF_Translucent) == PF_Translucent && (vPolyFlags&PF_Environment) != PF_Environment)
			DistanceFogParams.FogColor = vec4(0.0,0.0,0.0,0.0);
        else DistanceFogParams.FogColor = vDistanceFogColor;

		DistanceFogParams.FogCoord = abs(vEyeSpacePos.z/vEyeSpacePos.w);
		TotalColor = mix(TotalColor, DistanceFogParams.FogColor, getFogFactor(DistanceFogParams));
	}
#endif

	if((vPolyFlags & PF_Modulated)!=PF_Modulated)
	{
		// Gamma
#ifdef GL_ES
		// 1.055*pow(x,(1.0 / 2.4) ) - 0.055
		// FixMe: ugly rough srgb to linear conversion.
		TotalColor.r=(1.055*pow(TotalColor.r,(1.0-vGamma / 2.4))-0.055);
		TotalColor.g=(1.055*pow(TotalColor.g,(1.0-vGamma / 2.4))-0.055);
		TotalColor.b=(1.055*pow(TotalColor.b,(1.0-vGamma / 2.4))-0.055);
#else
		TotalColor.r=pow(TotalColor.r,2.7-vGamma*1.7);
		TotalColor.g=pow(TotalColor.g,2.7-vGamma*1.7);
		TotalColor.b=pow(TotalColor.b,2.7-vGamma*1.7);
#endif
	}

#if EDITOR
	// Editor support.
	if (vRendMap == REN_Zones || vRendMap == REN_PolyCuts || vRendMap == REN_Polys)
	{
		TotalColor +=0.5;
		TotalColor *= vDrawColor;
	}
	else if ( vRendMap==REN_Normals ) //Thank you han!
	{
		// Dot.
		float T = 0.5*dot(normalize(vCoords),vSurfaceNormal);

		// Selected.
		if ( (vPolyFlags&PF_Selected)==PF_Selected )
		{
			TotalColor = vec4(0.0,0.0,abs(T),1.0);
		}
		// Normal.
		else
		{
			TotalColor = vec4(max(0.0,T),max(0.0,-T),0.0,1.0);
		}
	}
	else if ( vRendMap==REN_PlainTex )
	{
		TotalColor = Color;
	}

	if ( (vRendMap!=REN_Normals)  && ((vPolyFlags&PF_Selected) == PF_Selected) )
	{
		TotalColor.r = (TotalColor.r*0.75);
        TotalColor.g = (TotalColor.g*0.75);
        TotalColor.b = (TotalColor.b*0.75) + 0.1;
		TotalColor = clamp(TotalColor,0.0,1.0);
		if(TotalColor.a < 0.5)
			TotalColor.a = 0.51;
	}

    // HitSelection, Zoneview etc.
	if (bHitTesting)
		TotalColor = vDrawColor; // Use ONLY DrawColor.

#endif

	//FragColor1	= mix(TotalColor,LightColor,1.0);// way to fix skybox etc??
	FragColor	= TotalColor;
}
#else
void main(void)
{
# if BINDLESSTEXTURES
    vec4 Color = texture(Textures[vBaseTexNum], vTexCoords);
# else
    vec4 Color = texture(Texture0, vTexCoords);
# endif
	FragColor = Color;
}
#endif

/*
//
// EnviroMap.
//
// Simple GLSL implementation of the C++ code. Should be obsoleted by some fancy
// per pixel sphere mapping implementation. But for now, just use this approach
// as PF_Environment handling is the last missing peace on obsoleting RenderSubsurface.
//
vec2 EnviroMap( vec3 Point, vec3 Normal )
{
	vec3 R = reflect(normalize(Point),Normal);
	return vec2(0.5*dot(R,Uncoords_XAxis)+0.5,0.5*dot(R,Uncoords_YAxis)+0.5);
}
*/
