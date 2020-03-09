struct VS_INPUT
{
	float3 pos : POSITION;
	float3 normal : NORMAL;
	float2 texCoord : TEXCOORD;
};

struct VS_OUTPUT
{
	float4 pos : WORLD_POS;
	float4 wvpPos : SV_POSITION;
	float3 normal : NORMAL;
	float2 texCoord : TEXCOORD;
};

cbuffer WvpConstantBuffer : register(b0)
{
	float4x4 world;
	float4x4 wvp;
	float3 cameraPos;
	float3 lightVec;
	float4x4 lightWvp;
};

Texture2D tex : register(t0);
Texture2D depthTex : register(t1);
SamplerState samplerState : register(s0);

VS_OUTPUT vsMain(VS_INPUT input)
{
	VS_OUTPUT output;

	output.pos = float4(input.pos, 1.0f);
	output.wvpPos = mul(output.pos, wvp);

	float3 worldNormal = mul(input.normal, world);
	output.normal = worldNormal;

	output.texCoord = input.texCoord;

	return output;
}

float4 psMain(VS_OUTPUT input) : SV_TARGET
{
	float4 baseColor = tex.Sample(samplerState, input.texCoord);
	float ambient = 0.2f;
	float diffuse = dot(-lightVec, input.normal);
	float3 cameraDir = normalize(cameraPos - float3(input.pos[0], input.pos[1], input.pos[2]));
	float3 specularDir = lightVec - 2 * dot(lightVec, input.normal) * input.normal;
	float specular = clamp(dot(specularDir, cameraDir), 0.0f, 1.0f);
	specular = pow(specular, 16);
	return clamp(baseColor * (ambient + 0.8 * diffuse + 5.0f * specular), 0.0f, 1.0f);
}

VS_OUTPUT vsDepth(VS_INPUT input)
{
	VS_OUTPUT output;

	output.pos = float4(input.pos, 1.0f);
	output.wvpPos = mul(output.pos, lightWvp);

	output.normal = input.normal;

	output.texCoord = input.texCoord;

	return output;
}

float4 psDepth(VS_OUTPUT input) : SV_TARGET
{
	return float4(0.0f, 0.0f, 0.0f, 1.0f);
}