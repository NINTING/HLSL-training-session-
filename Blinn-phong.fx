/*

% Description of my shader.
% Second line of description for my shader.

Blinn-phong Model

date: YYMMDD

*/

//
//extern var
//
extern matrix WorldViewProj;
extern matrix World;
extern matrix View;
extern matrix Proj;
extern matrix WorldView;

//
//static var
//
static vector LightDir 		  = {-3.0f,0.5f,1.0f,0.0f};
static vector diffuseLight 	  = {1.0f,1.0f,1.0f,1.0f};
static vector specularLight	  = {0.5f,0.5f,0.5f,1.0f};
static vector ambientLight 	  = {0.2,0.2,0.2,1};
static vector diffuseMaterial = {0,1,0,1};
static vector specularMaterial={0,1,1,1};
static float specularPower	  = 0.5f;

//
//vertex shader
//
struct V_INPUT{
	vector pos : POSITION;
	vector Normal : NORMAL;
};
struct V_OUTPUT{
	vector pos : POSITION;
	vector color : COLOR;
};


V_OUTPUT mainVS(V_INPUT input){
	V_OUTPUT output = (V_OUTPUT)0;
	
	output.pos 		= mul(input.pos,WorldViewProj);
	input.pos		= mul(input.pos,WorldView);
	input.Normal.w  = 0.0f;
	input.Normal 	= mul(input.Normal,WorldView);
	LightDir		= mul(LightDir    ,WorldView);
	input.Normal 	= normalize(input.Normal);		
	
	//diffuse Color
	LightDir		= -LightDir;
	float Dcos 		= saturate(dot(input.Normal,LightDir)) ;
	vector diffuseColor = ambientLight * diffuseMaterial +  Dcos*diffuseLight * diffuseMaterial;
	
	//specular Color
	vector v		= -input.pos;
	vector H		= normalize(v+LightDir);
	float Scos		= saturate(dot(input.Normal,H)) ;
	vector specularColor= specularLight*specularMaterial*pow(Scos,specularPower);

	output.color    = diffuseColor + specularColor;
	return output;
}
//
//Pixel shader
//
struct P_INPUT{
	vector pos : POSITION;
	vector color : COLOR;
};
struct P_OUTPUT{
	vector color : COLOR;
};

P_OUTPUT mainPS(P_INPUT input){
	
	P_OUTPUT output = (P_OUTPUT)0;
	output.color = input.color;
	
	return output;
}

technique technique0 {
	pass p0 {
		fvf = XYZ | NORMAL;
		CullMode = None;	
		Lighting = true;
		NormalizeNormals = true;
		SpecularEnable   = false;
		FillMode = SOLID;
		VertexShader = compile vs_3_0 mainVS();
		//PixelShader = compile ps_3_0 mainPS();
	}
}
