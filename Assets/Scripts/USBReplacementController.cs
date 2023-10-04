using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class USBReplacementController : MonoBehaviour
{
    // shader de reemplazo
    public Shader m_replacementShader;
    private void OnEnable()
    {
        if(m_replacementShader != null)
        {
            // la cámara va a reemplazar todos los shaders en la escena 
            // por aquel de reemplazo la configuración del render type
            // debe coincidir en ambos shaders
            GetComponent<Camera>().SetReplacementShader(
            m_replacementShader, "RenderType");
        }
    } 
    private void OnDisable()
    {
    // reseteamos al shader asignado
        GetComponent<Camera>().ResetReplacementShader();
    }
}
