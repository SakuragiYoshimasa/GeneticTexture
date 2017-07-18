using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderDesplament : MonoBehaviour {

	public RenderTexture tex;

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Graphics.Blit(tex, dest);
    }
}
