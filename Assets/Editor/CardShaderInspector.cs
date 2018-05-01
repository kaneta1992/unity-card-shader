using UnityEngine;
using System.Collections;
using UnityEditor;

public class Generator : ScriptableObject
{
    public Vector4 blendMode = Vector4.zero;
}

public class CardShaderInspector : MaterialEditor
{

    // マテリアルへのアクセス
    Material material
    {
        get
        {
            return (Material)target;
        }
    }

    bool[] showEffectSettings = { false, false, false, false, false };

    static string[] blendModes = new[] { "liner", "add", "sub", "mul" };
    static Vector4[] blendModesVector = new Vector4[] { new Vector4(1, 0, 0, 0), new Vector4(0, 1, 0, 0), new Vector4(0, 0, 1, 0), new Vector4(0, 0, 0, 1) };

    private void showBlendMode(int index)
    {
        EditorGUI.BeginChangeCheck();
        string numberString = (index + 1).ToString();
        MaterialProperty blend = GetMaterialProperty(targets, "_Effect" + numberString + "BlendMode");
        Vector4 data = blend.vectorValue;
        int mode = 0;
        if (data.x > 0.9)
        {
            mode = 0;
        }
        else if (data.y > 0.9)
        {
            mode = 1;
        }
        else if (data.z > 0.9)
        {
            mode = 2;
        }
        else if (data.w > 0.9)
        {
            mode = 3;
        }
        mode = EditorGUILayout.Popup("Blend Mode", mode, blendModes);
        if (EditorGUI.EndChangeCheck())
        {
            Vector4 vec = blendModesVector[mode];
            material.SetVector("_Effect" + numberString + "BlendMode", vec);
            EditorUtility.SetDirty(material);
        }
    }

    private void showPulse(int index)
    {
        EditorGUILayout.PrefixLabel("Pulse");   
        EditorGUI.indentLevel++;
        EditorGUI.BeginChangeCheck();

        string numberString = (index + 1).ToString();
        MaterialProperty pulse = GetMaterialProperty(targets, "_Effect" + numberString + "Pulse");
        Vector4 data = pulse.vectorValue;

        float freq = data.x;
        Vector2 phase = new Vector2(data.y, data.z);
        float power = data.w;
        freq = EditorGUILayout.FloatField("freq", freq);
        phase = EditorGUILayout.Vector2Field("phase", phase);
        power = EditorGUILayout.FloatField("power", power);

        if (EditorGUI.EndChangeCheck())
        {
            material.SetVector("_Effect" + numberString + "Pulse", new Vector4(freq, phase.x, phase.y, power));
            EditorUtility.SetDirty(material);
        }
        EditorGUI.indentLevel--;
    }

    private void showCoord(int index)
    {
        EditorGUILayout.PrefixLabel("Coord");
        EditorGUI.indentLevel++;
        EditorGUI.BeginChangeCheck();

        string numberString = (index + 1).ToString();
        MaterialProperty coord1 = GetMaterialProperty(targets, "_Effect" + numberString + "Coord1");
        MaterialProperty coord2 = GetMaterialProperty(targets, "_Effect" + numberString + "Coord2");
        Vector4 coord1Vec = coord1.vectorValue;
        Vector4 coord2Vec = coord2.vectorValue;

        Vector2 origin = new Vector2(coord1Vec.x, coord1Vec.y);
        Vector2 dtVec = new Vector2(coord1Vec.z, coord1Vec.w);
        float angle = coord2Vec.x;
        float dtAngle = coord2Vec.y;
        origin = EditorGUILayout.Vector2Field("origin", origin);
        angle = EditorGUILayout.FloatField("angle", angle);
        dtVec = EditorGUILayout.Vector2Field("dtVec", dtVec);
        dtAngle = EditorGUILayout.FloatField("dtAngle", dtAngle);

        if (EditorGUI.EndChangeCheck())
        {
            material.SetVector("_Effect" + numberString + "Coord1", new Vector4(origin.x, origin.y, dtVec.x, dtVec.y));
            material.SetVector("_Effect" + numberString + "Coord2", new Vector4(angle, dtAngle, 0, 0));
            EditorUtility.SetDirty(material);
        }
        EditorGUI.indentLevel--;
    }

    private void buildEffectPropertiesLayout(int index)
    {
        string numberString = (index + 1).ToString();
        showEffectSettings[index] = EditorGUILayout.Foldout(showEffectSettings[index], "Effect" + numberString);
        if (showEffectSettings[index])
        {
            EditorGUI.BeginChangeCheck();
            // 1段下げてUIを表示
            EditorGUI.indentLevel = 1;
            MaterialProperty prop = GetMaterialProperty(targets, "_Blend" + numberString + "Tex");
            TextureProperty(prop, "Texture(RGBA)", true);
            showCoord(index);
            showPulse(index);
            showBlendMode(index);
            EditorGUI.indentLevel = 0;

            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(material);
            }
        }
    }

    // Inspectorに表示される内容
    public override void OnInspectorGUI()
    {
        // マテリアルを閉じた時に非表示にする
        if (isVisible == false) { return; }

        MaterialProperty mask1 = GetMaterialProperty(targets, "_Mask1Tex");
        TextureProperty(mask1, "Mask1", false);

        MaterialProperty mask2 = GetMaterialProperty(targets, "_Mask2Tex");
        TextureProperty(mask2, "Mask2", false);

        for(int i = 0; i < 5; i++)
        {
            buildEffectPropertiesLayout(i);
        }
    }
}