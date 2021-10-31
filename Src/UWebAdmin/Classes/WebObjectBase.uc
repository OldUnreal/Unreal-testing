Class WebObjectBase extends Object
	native
	abstract;

struct PreferencesInfo
{
	var string Caption,ParentCaption,ClassName;
	var name Category;
	var bool Immediate;
};
struct VariableInfo
{
	var string VarDesc; // Variable description
	var name VarName; // Variable name
	var byte VarType; // Variable type
	var int NumElements; // Number of elements, 1> = static array, 0< = dynamic array
	var array<string> Value; // Current value
	var array<name> EnumList; // Enum elements available.
};
/* VarTypes:
0 - int
1 - float
2 - byte
3 - enum
4 - string
5 - object/class
6 - struct
7 - bool
8 - unknown */
