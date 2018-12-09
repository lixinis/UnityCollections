using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DiffusePreRender : MonoBehaviour
{
	public Material m_TextureSpaceMat;
	public Shader m_BlurShader;
	private Material m_BlurMaterial;

	const int TEXTURE_SIZE = 1024;
	const int iteration = 5;
	RenderTexture[] rts;
	Mesh mesh;
	Material combineMaterial;

	private Dictionary<Camera,CommandBuffer> m_Cameras = new Dictionary<Camera,CommandBuffer>();

	private void Cleanup()
	{
		foreach (var cam in m_Cameras)
		{
			if (cam.Key)
			{
				cam.Key.RemoveCommandBuffer (CameraEvent.BeforeForwardOpaque, cam.Value);
			}
		}
		m_Cameras.Clear();
		Object.DestroyImmediate(m_BlurMaterial);
	}

    void Awake()
    {
		mesh = GetComponent<MeshFilter>().mesh;
		combineMaterial = GetComponent<MeshRenderer>().sharedMaterial;
		rts = new RenderTexture[iteration];
		for (var i = 0; i < iteration; i++)
		{
        	rts[i] = new RenderTexture(TEXTURE_SIZE, TEXTURE_SIZE, 0, RenderTextureFormat.ARGB32);
		}
		combineMaterial.SetTexture("_DiffuseTex0", rts[0]);
    }

	public void OnEnable()
	{
		Cleanup();
	}

	public void OnDisable()
	{
		Cleanup();
	}
	
	void OnWillRenderObject() 
	{
		var cam = Camera.current;
		if (!cam)
			return;

		CommandBuffer buf = null;
		if (m_Cameras.ContainsKey(cam))
			return;

		if (!m_BlurMaterial)
		{
			m_BlurMaterial = new Material(m_BlurShader);
			m_BlurMaterial.hideFlags = HideFlags.HideAndDontSave;
		}
		buf = new CommandBuffer();
		m_Cameras[cam] = buf;

		buf.SetRenderTarget(rts[0]);
		buf.DrawMesh(mesh, transform.localToWorldMatrix, m_TextureSpaceMat);

		cam.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, buf);
	}
}
