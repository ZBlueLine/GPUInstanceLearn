using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class GrassTerrain : MonoBehaviour
{
    private static List<GrassTerrain> mGrassTerrainList = new List<GrassTerrain>();

    public Mesh GrassMesh;

    public int GrassCountPerVert = 100;

    [Range(0, 1)]
    public float GrassSize = 1;
    public int MaxGrassCount = 50000;

    public static IReadOnlyList<GrassTerrain> GrassTerrainList
    {
        get { return mGrassTerrainList; }
    }
    public ComputeBuffer GrassInfoBuffer
    {
        get
        {
            if (grassInfoBuffer != null)
            {
                return grassInfoBuffer;
            }
            CommandBuffer cmd = new CommandBuffer();
            List<GrassInfo> grassInfoList = new List<GrassInfo>();
            int grassInfoCount = 0;
            foreach (var vert in TerrainMesh.vertices)
            {
                for (int i = 0; i < GrassCountPerVert; ++i)
                {
                    Vector3 pos = vert + new Vector3(Random.Range(0f, 1f), Random.Range(0f, 0.5f), Random.Range(0f, 1f));
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

            grassInfoBuffer = new ComputeBuffer(grassInfoCount, 64);
            grassInfoBuffer.SetData(grassInfoList.ToArray());
            return grassInfoBuffer;
        }
    }

    private ComputeBuffer grassInfoBuffer;

    public void OnEnable()
    {
        mGrassTerrainList.Add(this);
    }

    public void OnDisable()
    {
        mGrassTerrainList.Remove(this);
        if(grassInfoBuffer != null)
        {
            grassInfoBuffer.Dispose();
            grassInfoBuffer = null;
        }
    }

    private Mesh TerrainMesh
    {
        get => GetComponent<MeshFilter>().sharedMesh;
    }
    private struct GrassInfo
    {
        public Matrix4x4 localToTerrianMatrix;
    }
}
