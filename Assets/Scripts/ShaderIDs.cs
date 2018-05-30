using UnityEngine;

public static class ShaderIDs{
	//Some Examples
	public static int _MainTex = Shader.PropertyToID("_MainTex");
    //Use id value instead of string could have less cost.
    //Set your custom variables here
    public static int _TempTex = Shader.PropertyToID("_TempTex");
    public static int _DepthTex = Shader.PropertyToID("_DepthTexture");
    public static int _MirrorNormal = Shader.PropertyToID("_MirrorNormal");
    public static int _MirrorPos = Shader.PropertyToID("_MirrorPos");
    public static int _BlurOffset = Shader.PropertyToID("_BlurOffset");
    public static int _ScreenTexture = Shader.PropertyToID("_ScreenTexture");
    public static int CurrentBuffer = Shader.PropertyToID("CurrentBuffer"); //Compute shader
    public static int results = Shader.PropertyToID("results"); //Compute Shader
    public static int _RandomSeed = Shader.PropertyToID("_RandomSeed");
    public static int _DeltaTime = Shader.PropertyToID("_DeltaTime");
}
