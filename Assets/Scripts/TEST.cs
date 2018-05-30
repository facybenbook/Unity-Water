using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
public class TEST : MonoBehaviour {
    private CommandBuffer buffer;
    private CommandBuffer drawbuffer;
    public RenderTexture rt;
    private Camera cam;
    public Renderer occlude;
	// Use this for initialization
	void Start () {
        cam = GetComponent<Camera>();
        buffer = new CommandBuffer();
        drawbuffer = new CommandBuffer();
       // drawbuffer.GetTemporaryRT(ShaderIDs._TempTex, cam.pixelWidth, cam.pixelHeight, 0, FilterMode.Bilinear, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.Default);
        drawbuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        drawbuffer.ClearRenderTarget(true, true, Color.black);
        drawbuffer.DrawRenderer(occlude, occlude.sharedMaterial);
        cam.AddCommandBuffer(CameraEvent.BeforeGBuffer, drawbuffer);
        buffer.Blit(BuiltinRenderTextureType.GBuffer2, rt);
        cam.AddCommandBuffer(CameraEvent.AfterGBuffer, buffer);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
