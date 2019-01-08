using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeTest : MonoBehaviour
{
    public ComputeShader shader;
    private MeshRenderer mr;
    private RenderTexture tex;

    private void Awake() {
        tex = new RenderTexture(256,256,24);
        tex.enableRandomWrite = true;
        tex.Create();

        mr = GetComponent<MeshRenderer>();
        mr.sharedMaterial.mainTexture = tex;
    }

    void RunShader()
    {
        int kernelHandle = shader.FindKernel("CSMain");

        shader.SetTexture(kernelHandle, "Result", tex);
        shader.Dispatch(kernelHandle, 256/8, 256/8, 1);
    }

    private void Update() 
    {
        RunShader();
    }
}
