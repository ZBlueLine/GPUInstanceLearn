using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class BlueGrassInstance : MonoBehaviour
{
    public Mesh GrassMesh;
    public Material GrassMaterial;
    public int MaxGrassCount = 2000;
    public int GrassCountPerVert = 10;
    [Range(0, 2)]
    public float GrassSize = 1;
    public GameObject TerrainObj;

    private Mesh TerrainMesh;
    private Camera cam;

    struct GrassInfo
    {
        public Matrix4x4 localToTerrianMatrix;
    }

    private void Start()
    {
        Init();
        RenderGrass();
    }

    //private void OnEnable()
    //{
    //    Init();
    //    RenderGrass();
    //}

    private bool Init()
    {
        cam = GetComponent<Camera>();
        if (TerrainObj == null)
            if (cam == null)
            {
                Debug.LogError("未找到相机");
                return false;
            }
        if (TerrainObj == null)
        {
            Debug.LogError("没有设置地形OBJ");
            return false;
        }
        if (GrassMesh == null)
        {
            Debug.LogError("没有设置草的mesh");
            return false;
        }
        if (GrassMaterial == null)
        {
            Debug.LogError("没有设置草的材质");
            return false;
        }
        if (TerrainMesh == null)
        {
            TerrainMesh = TerrainObj.GetComponent<MeshFilter>().mesh;
        }
        return true;
    }

    void RenderGrass()
    {
        CommandBuffer cmd = new CommandBuffer();
        List<GrassInfo> grassInfoList = new List<GrassInfo>();
        int grassInfoCount = 0;
        foreach (var vert in TerrainMesh.vertices)
        {
            for (int i = 0; i < GrassCountPerVert; ++i)
            {
                Vector3 pos = vert +  new Vector3(Random.Range(0f, 1f), Random.Range(0f, 0.5f), Random.Range(0f, 1f));
                float rot = Random.Range(0, 180);

                Matrix4x4 localToTerrianMatrix = Matrix4x4.TRS(pos, Quaternion.Euler(0, rot, 0), Vector3.one);
                GrassInfo grassInfo = new GrassInfo() { localToTerrianMatrix = localToTerrianMatrix };
                grassInfoList.Add(grassInfo);
                ++grassInfoCount;
                if (grassInfoCount > MaxGrassCount)
                    break;
            }
            if (grassInfoCount > MaxGrassCount)
                break;
        }

        ComputeBuffer grassInfoBuffer = new ComputeBuffer(grassInfoCount, 64);
        grassInfoBuffer.SetData(grassInfoList.ToArray());

        MaterialPropertyBlock materialPropertyBlock = new MaterialPropertyBlock();
        materialPropertyBlock.SetMatrix("_TerrainToWorldMatrix", TerrainObj.transform.localToWorldMatrix);
        materialPropertyBlock.SetBuffer("GrassBuffer", grassInfoBuffer);
        materialPropertyBlock.SetFloat("_GrassQuadSize", GrassSize);

        cmd.DrawMeshInstancedProcedural(GrassMesh, 0, GrassMaterial, 0, grassInfoCount, materialPropertyBlock);
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cmd);
        cmd.Release();
    }
}
