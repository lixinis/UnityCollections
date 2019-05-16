using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class SSAO : MonoBehaviour
{
    public Shader ssaoShader;
    private Material ssaoMaterial;

    private Camera camera;
    // Start is called before the first frame update
    void Start()
    {
        CheckResources();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void CheckResources()
    {
        if (!camera)
        {
            camera = GetComponent<Camera>();
            camera.depthTextureMode |= DepthTextureMode.DepthNormals;
        }
        if (!ssaoMaterial)
        {
            ssaoMaterial = new Material(ssaoShader);
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        CheckResources();
        Graphics.Blit(src, dest, ssaoMaterial);
    }
}
