using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class USBComputeBUffer : MonoBehaviour
{
    public ComputeShader m_shader;

    [Range(0.0f, 0.5f)] public float m_radius = 0.5f;
    [Range(0.0f, 1.0f)] public float m_center = 0.5f;
    [Range(0.0f, 0.5f)] public float m_smooth = 0.01f;
    public Color m_mainColor = new Color();

    private RenderTexture m_mainTex;
    private int m_texSize = 128;
    private Renderer m_rend;

    //declaramos un struct con la lista de valores
    struct Circle
    {
        public float radius;
        public float center;
        public float smooth;
    }
    // declaramos una lista de tipo Circle para acceder a cada variable
    Circle[] m_circle;
    // declaramos un buffer de tipo ComputeBuffer
    ComputeBuffer m_buffer;

    void Start()
    {
        CreateShaderTex();
    }
    void CreateShaderTex()
    {
        // primero creamos la textura
        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0,
        RenderTextureFormat.ARGB32);
        m_mainTex.enableRandomWrite = true;
        m_mainTex.Create();
        // luego accedemos al mesh renderer
        m_rend = GetComponent<Renderer>();
        m_rend.enabled = true;
    }

    void Update()
    {
        SetShaderTex();
    }
    void SetShaderTex()
    {
        uint threadGroupSizeX;
        m_shader.GetKernelThreadGroupSizes(0, out threadGroupSizeX, out _,out _);
        int size = (int)threadGroupSizeX;
        m_circle = new Circle[size];

        for (int i = 0; i < size; i++)
        {
            Circle circle = m_circle[i];
            circle.radius = m_radius;
            circle.center = m_center;
            circle.smooth = m_smooth;
            m_circle[i] = circle;
        }

        int stride = 12;
        m_buffer = new ComputeBuffer(m_circle.Length, stride,ComputeBufferType.Default);
        m_buffer.SetData(m_circle);
        m_shader.SetBuffer(0, "CircleBuffer", m_buffer);
        m_shader.SetTexture(0, "Result", m_mainTex);
        m_shader.SetVector("MainColor", m_mainColor);
        m_rend.material.SetTexture("_MainTex", m_mainTex);
        m_shader.Dispatch(0, m_texSize, m_texSize, 1);
        m_buffer.Release();
    }
}
