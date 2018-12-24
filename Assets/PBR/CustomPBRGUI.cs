using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CustomPBRGUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent albedoText = EditorGUIUtility.TrTextContent("Albedo");
        public static GUIContent metallicRoughnessText = EditorGUIUtility.TrTextContent("Metallic&Roughness");
    }

    MaterialEditor m_MaterialEditor;
    bool m_FirstTimeApply = true;

    MaterialProperty albedoMap;
    MaterialProperty metallicAndRoughnessMap;
    MaterialProperty metallic;
    MaterialProperty roughness;

    public void FindProperties(MaterialProperty[] props)
    {
        albedoMap = FindProperty("_Albedo", props);
        metallicAndRoughnessMap = FindProperty("_MetalRoughness", props);
        metallic = FindProperty("_Metallic", props);
        roughness = FindProperty("_Roughness", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        if (m_FirstTimeApply)
        {
            MaterialChanged(material);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUI.BeginChangeCheck();
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap);
            m_MaterialEditor.TexturePropertySingleLine(Styles.metallicRoughnessText, metallicAndRoughnessMap);
            if (metallicAndRoughnessMap.textureValue == null)
            {
                m_MaterialEditor.ShaderProperty(metallic, "Metallic");
                m_MaterialEditor.ShaderProperty(roughness, "Roughness");
            }
        }
        if (EditorGUI.EndChangeCheck())
        {
            MaterialChanged(material);
        }
    }

    void MaterialChanged(Material material)
    {
        SetMaterialKeywords(material);
    }

    void SetMaterialKeywords(Material material)
    {
        SetKeyword(material, "_METALLICROUGHNESSMAP", material.GetTexture("_MetalRoughness"));
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }
}
