using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneticTexture : MonoBehaviour {

	public RenderTexture dest;
	
	int width = 1080;
	int height = 720;
	const int GENE_SIZE = 4;

	ComputeBuffer prevGeneBuffer;
	ComputeBuffer currGeneBuffer;
	[SerializeField] ComputeShader kernel;
	[SerializeField] Material geneticMat;
	

	void Start () {			
		InitBuffers();
		
	}
	
	void Update(){
		geneticMat.SetBuffer("_GeneBuffer", currGeneBuffer);
		geneticMat.SetInt("_Width", width);
		geneticMat.SetInt("_Height", height);
		Graphics.Blit(null, dest, geneticMat);

		int _kernel = kernel.FindKernel("init");
		prevGeneBuffer = currGeneBuffer;
		kernel.SetBuffer(_kernel, "PrevGeneBuffer", prevGeneBuffer);
		kernel.SetBuffer(_kernel, "CurrGeneBuffer", currGeneBuffer);
		kernel.SetFloat("_Time", Time.fixedTime);
		kernel.SetInt("_TexSize", width * height);
		//kernel.Dispatch(_kernel, width * height / 8, 1, 1);
	}
	
	
	void LateUpdate () {
		int _kernel = kernel.FindKernel("Kernel");
		prevGeneBuffer = currGeneBuffer;

		kernel.SetBuffer(_kernel, "PrevGeneBuffer", prevGeneBuffer);
		kernel.SetBuffer(_kernel, "CurrGeneBuffer", currGeneBuffer);
		kernel.SetFloat("_Time", Time.fixedTime);
		kernel.SetInt("_TexSize", width * height);
		kernel.Dispatch(_kernel, width * height / 8, 1, 1);
	}

	void InitBuffers(){
		if(prevGeneBuffer != null) prevGeneBuffer.Release();
		if(currGeneBuffer != null) currGeneBuffer.Release();

		prevGeneBuffer = new ComputeBuffer(width * height, sizeof(float) * GENE_SIZE);
		currGeneBuffer = new ComputeBuffer(width * height, sizeof(float) * GENE_SIZE);
	}

	void OnDestroy(){
		if(prevGeneBuffer != null) prevGeneBuffer.Release();
		if(currGeneBuffer != null) currGeneBuffer.Release();
	}
}
