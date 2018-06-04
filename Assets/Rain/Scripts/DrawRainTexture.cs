using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
public class DrawRainTexture : MonoBehaviour {
    private CommandBuffer buffer;
    public RenderTexture targetTexture;
    static int colors = Shader.PropertyToID("colors");
    Matrix4x4[] matrix = new Matrix4x4[COUNT];
    float[] times = new float[COUNT];
    public Material mat;
    public ComputeShader shader;
    private int kernal;
    // Use this for initialization
    ComputeBuffer matrixBuffers;
    ComputeBuffer timeSliceBuffers;
    const int COUNT = 1023;
    const float SCALE = 0.03f;
    void Awake () {
        buffer = new CommandBuffer();
        for (int i = 0; i < COUNT; ++i) {
            times[i] = Random.Range(-1f, 1f);
            matrix[i] = Matrix4x4.identity;
            matrix[i].m00 = SCALE;
            matrix[i].m11 = SCALE;
            matrix[i].m22 = SCALE;
            matrix[i].m03 = Random.Range(-1f, 1f);
            matrix[i].m13 = Random.Range(-1f, 1f);
        }
        matrixBuffers = new ComputeBuffer(COUNT, 64);
        matrixBuffers.SetData(matrix);
        timeSliceBuffers = new ComputeBuffer(COUNT, 4);
        timeSliceBuffers.SetData(times);
        kernal = shader.FindKernel("CSMain");
        shader.SetBuffer(kernal, ShaderIDs.matrixBuffer, matrixBuffers);
        shader.SetBuffer(kernal, ShaderIDs.timeSliceBuffer, timeSliceBuffers);
        
    }

    private void Update()
    {
        shader.Dispatch(kernal, COUNT, 1, 1);
        buffer.Clear();
        buffer.SetRenderTarget(targetTexture);
        buffer.ClearRenderTarget(true, true, new Color(0.5f, 0.5f, 1, 1));
        buffer.SetGlobalBuffer(ShaderIDs.timeSliceBuffer, timeSliceBuffers);
        matrixBuffers.GetData(matrix);
        buffer.DrawMeshInstanced(GraphicsUtility.fullScreenMesh, 0, mat, 0, matrix);
        shader.SetFloat(ShaderIDs._DeltaFlashSpeed, Time.deltaTime * 1.5f);
        Graphics.ExecuteCommandBuffer(buffer);
    }

    // Update is called once per frame
    void OnDestroy () {
        buffer.Dispose();
        timeSliceBuffers.Dispose();
        matrixBuffers.Dispose();
	}
}
