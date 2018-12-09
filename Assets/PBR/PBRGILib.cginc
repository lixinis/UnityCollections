#ifndef CUSTOM_PBR_GI_LIB
#define CUSTOM_PBR_GI_LIB

#include "UnityLightingCommon.cginc"

#ifndef UNITY_SPECCUBE_LOD_STEPS
#define UNITY_SPECCUBE_LOD_STEPS (6)
#endif

half perceptualRoughnessToMipmapLevel(half perceptualRoughness)
{
    return perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
}

half3 GI_Base()
{
    
}

half3 GI_IndirectSpecular(half roughness, half occlusion, half3 reflectDir)
{
    half perceptualRoughness = roughness * (1.7 - 0.7 * roughness); // from unity hack?
    half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mip);
    return DecodeHDR(rgbm, unity_SpecCube0_HDR) * occlusion;
}

#endif