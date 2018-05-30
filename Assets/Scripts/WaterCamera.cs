using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class WaterCamera : MonoBehaviour {
    private CommandBuffer buffer;
    private CommandBuffer drawBuffer;
    private Camera cam;
    private int width, height;

    public RenderTexture heightMap;
    private ComputeBuffer waveCalculationBuffer;
    private ComputeBuffer waveBuffer;
    public ComputeShader shader;
    private int kernel;
    public Material heightmapMaterial;
    const int WAVECOUNT = 1024;
    
    struct WaveCalculation{
        public Vector3 value0;
        public Vector3 value1;
        public Vector3 value2;
        public Vector3 value3;
        public float timeLine;
        public float speed;
    }
    private WaveCalculation[] calculationArrays = new WaveCalculation[WAVECOUNT];
    private Vector3[] resultArrays = new Vector3[WAVECOUNT];
	// Use this for initialization
	void Awake () {
        cam = GetComponent<Camera>();
        buffer = new CommandBuffer();
        width = -1;
        height = -1;
        waveCalculationBuffer = new ComputeBuffer(WAVECOUNT, 56);
        waveBuffer = new ComputeBuffer(WAVECOUNT, 12);
        for (int i = 0; i < WAVECOUNT; ++i) {
            WaveCalculation value;
            value.value0 = new Vector3(Random.Range(-10f, 10f), Random.Range(-10f, 10f), Random.Range(-10f, 10f)).normalized;
            value.value1 = new Vector3(Random.Range(-10f, 10f), Random.Range(-10f, 10f), Random.Range(-10f, 10f)).normalized;
            value.value2 = new Vector3(Random.Range(-10f, 10f), Random.Range(-10f, 10f), Random.Range(-10f, 10f)).normalized;
            value.value3 = new Vector3(Random.Range(-10f, 10f), Random.Range(-10f, 10f), Random.Range(-10f, 10f)).normalized;
            value.timeLine = 0;
            value.speed = 1;
            calculationArrays[i] = value;
            resultArrays[i] = Vector3.zero;
        }
        waveCalculationBuffer.SetData(calculationArrays);
        waveBuffer.SetData(resultArrays);
        kernel = shader.FindKernel("CSMain");
        InitCompute();
        drawBuffer = new CommandBuffer();
        drawBuffer.BlitSRT(heightMap, heightmapMaterial, 0);
	}

    private void Update()
    {
        UpdatePosition();
    }

    private void OnDestroy()
    {
        buffer.Dispose();
        waveCalculationBuffer.Dispose();
        waveBuffer.Dispose();
    }

    private void RunComputeShader() {
        shader.SetBuffer(kernel, ShaderIDs.CurrentBuffer, waveCalculationBuffer);
        shader.SetBuffer(kernel, ShaderIDs.results, waveBuffer);
        shader.Dispatch(kernel, WAVECOUNT, 1, 1);
    }

    private void OnEnable()
    {
        cam.AddCommandBuffer(CameraEvent.BeforeForwardAlpha, buffer);
    }

    private void OnDisable()
    {
        cam.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, buffer);
    }

    // Update is called once per frame
    private void OnPreRender()
    {
        if (width != cam.pixelWidth || height != cam.pixelHeight) {
            width = cam.pixelWidth;
            height = cam.pixelHeight;
            buffer.Clear();
            buffer.GetTemporaryRT(ShaderIDs._ScreenTexture, width, height, 0, FilterMode.Trilinear, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.Default);
            buffer.Blit(BuiltinRenderTextureType.CameraTarget, ShaderIDs._ScreenTexture);
        }
    }

    #region DEBUG
    Vector3[] results = new Vector3[WAVECOUNT];
    Transform[] gameObjects = new Transform[WAVECOUNT];
    Vector3[] initPosition = new Vector3[WAVECOUNT];
    public Transform parent;
    private void InitCompute() {
        int min = Mathf.Min(WAVECOUNT, parent.childCount);
        for (int i = 0; i < min; ++i) {
            gameObjects[i] = parent.GetChild(i);
            initPosition[i] = gameObjects[i].position;
        }
    }

    private void UpdatePosition() {
        shader.SetFloat(ShaderIDs._DeltaTime, Time.deltaTime);
        shader.SetVector(ShaderIDs._RandomSeed, new Vector3(Random.Range(-10f, 10f), Random.Range(-10f, 10f), Random.Range(-10f, 10f)));
        RunComputeShader();
        waveBuffer.GetData(results);
        for (int i = 0; i < WAVECOUNT; ++i) {
            gameObjects[i].position = initPosition[i] + results[i];
        }
    }
    #endregion
}
