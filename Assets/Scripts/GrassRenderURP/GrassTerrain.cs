using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class GrassTerrain : MonoBehaviour
{
    private static List<GrassTerrain> mGrassTerrainList = new List<GrassTerrain>();

    [Range(0, 2)]
    public float Height;

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
            int[] indices = TerrainMesh.triangles;
            for(int t = 0; t < indices.Length / 3; ++t)
            {
                int index = indices[t * 3];
                int index1 = indices[t * 3 + 1];
                int index2 = indices[t * 3 + 2];
                Vector3 v1 = TerrainMesh.vertices[index];
                Vector3 v2 = TerrainMesh.vertices[index1];
                Vector3 v3 = TerrainMesh.vertices[index2];
                Vector3 e1 = v2 - v1;
                Vector3 e2 = v3 - v1;
                Vector3 normalDir = Vector3.Cross(e1, e2).normalized;
                for (int i = 0; i < GrassCountPerVert; ++i)
                {
                    ++grassInfoCount;
                    if (grassInfoCount >= MaxGrassCount)
                        break;
                    Vector3 randomPos = GetRandomPos(e1, e2, v1);
                    Vector3 pos = randomPos;
                    //pos[1] += Height;
                    float rot = Random.Range(0, 180);
                    Quaternion grassDir = Quaternion.FromToRotation(Vector3.up, normalDir);
                    Matrix4x4 localToTerrianMatrix = Matrix4x4.TRS(pos, grassDir * Quaternion.Euler(0, rot, 0), Vector3.one);
                    GrassInfo grassInfo = new GrassInfo() { localToTerrianMatrix = localToTerrianMatrix };
                    grassInfoList.Add(grassInfo);
                }
                if (grassInfoCount >= MaxGrassCount)
                    break;
            }
            grassInfoBuffer = new ComputeBuffer(grassInfoCount, 64);
            grassInfoBuffer.SetData(grassInfoList.ToArray());
            return grassInfoBuffer;
        }
    }

    private Vector3 GetRandomPos(Vector3 e1, Vector3 e2, Vector3 v1)
    {
        float x = Random.Range(0f, 1f);
        float y = Random.Range(0f, 1f);
        if (y > 1 - x)
        {
            float temp = y;
            y = 1 - x;
            x = 1 - temp;
        }
        return e1 * x + e2 * y + v1;
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
