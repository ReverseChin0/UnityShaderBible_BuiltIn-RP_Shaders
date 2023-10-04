using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class USB_Simple_Color_Contoller : MonoBehaviour
{
    public ComputeShader m_shader;
    public Texture m_tex;

    public RenderTexture m_mainTex;
    int m_texSize = 256;
    Renderer m_rend;
    void Start()
    {
        // inicializamos la textura.
        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0,
        RenderTextureFormat.ARGB32);
        // habilitamos la escritura aleatoria
        m_mainTex.enableRandomWrite = true;
        // creamos la textura como tal
        m_mainTex.Create();

        // obtenemos el componente renderer del material
        m_rend = GetComponent<Renderer>();
        // hacemos el objeto visible
        m_rend.enabled = true;
        // enviamos la textura al Compute Shader.
        m_shader.SetTexture(0, "Result", m_mainTex); //accede al shader 0
        m_shader.SetTexture(0, "ColTex", m_tex);
        // enviamos la textura al material del Quad.
        m_rend.material.SetTexture("_MainTex", m_mainTex);
        // generamos los grupos de hilos para procesar la textura
        m_shader.Dispatch(0, m_texSize / 8, m_texSize / 8, 1);
    }
    
    void Update()
    {
        
    }
}
