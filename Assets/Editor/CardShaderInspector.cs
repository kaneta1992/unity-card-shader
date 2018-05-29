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

    static string[] coordModes = new[] { "UV", "Polar" };
    static float[] coordModesValue = new float[] { 0.0f, 1.0f };

    static string[] useMasks = new[] { "none", "R", "G", "B", "A" };
    static Vector4[] useMasksVector = new Vector4[] { Vector4.zero, new Vector4(1, 0, 0, 0), new Vector4(0, 1, 0, 0), new Vector4(0, 0, 1, 0), new Vector4(0, 0, 0, 1) };

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
        Vector2 offset = new Vector2(data.y, data.z);
        float intensity = data.w;
        freq = EditorGUILayout.FloatField("freq", freq);
        offset = EditorGUILayout.Vector2Field("offset", offset);
        intensity = EditorGUILayout.FloatField("intensity", intensity);

        if (EditorGUI.EndChangeCheck())
        {
            material.SetVector("_Effect" + numberString + "Pulse", new Vector4(freq, offset.x, offset.y, intensity));
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
        float coord = coord2Vec.z;
        int coordIndex = coord > 0.5 ? 1 : 0;
        coordIndex = EditorGUILayout.Popup("coord", coordIndex, coordModes);
        if (coordIndex == 0)
        {
            origin = EditorGUILayout.Vector2Field("origin", origin);
        }
        angle = EditorGUILayout.FloatField("angle", angle);
        dtVec = EditorGUILayout.Vector2Field("dtVec", dtVec);
        dtAngle = EditorGUILayout.FloatField("dtAngle", dtAngle);

        if (EditorGUI.EndChangeCheck())
        {
            material.SetVector("_Effect" + numberString + "Coord1", new Vector4(origin.x, origin.y, dtVec.x, dtVec.y));
            material.SetVector("_Effect" + numberString + "Coord2", new Vector4(angle, dtAngle, coordModesValue[coordIndex], 0));
            EditorUtility.SetDirty(material);
        }
        EditorGUI.indentLevel--;
    }

    private void showUseMask(int index)
    {
        EditorGUI.BeginChangeCheck();
        string numberString = (index + 1).ToString();
        MaterialProperty mask = GetMaterialProperty(targets, "_Effect" + numberString + "UseMask");
        Vector4 data = mask.vectorValue;
        int mode = 0;
        if (data.x > 0.9)
        {
            mode = 1;
        }
        else if (data.y > 0.9)
        {
            mode = 2;
        }
        else if (data.z > 0.9)
        {
            mode = 3;
        }
        else if (data.w > 0.9)
        {
            mode = 4;
        }
        mode = EditorGUILayout.Popup("Use Mask", mode, useMasks);
        if (EditorGUI.EndChangeCheck())
        {
            Vector4 vec = useMasksVector[mode];
            material.SetVector("_Effect" + numberString + "UseMask", vec);
            EditorUtility.SetDirty(material);
        }
    }

    private void showWave()
    {
        EditorGUILayout.PrefixLabel("Wave");
        EditorGUI.indentLevel = 1;
        EditorGUI.BeginChangeCheck();

        MaterialProperty value1Prop = GetMaterialProperty(targets, "_WaveValue1");
        MaterialProperty value2Prop = GetMaterialProperty(targets, "_WaveValue2");
        MaterialProperty maskProp = GetMaterialProperty(targets, "_WaveUseMask");
        Vector4 value1 = value1Prop.vectorValue;
        Vector4 value2 = value2Prop.vectorValue;
        Vector4 mask = maskProp.vectorValue;

        int mode = 0;
        Vector2 offset_x = new Vector2(value1.x, value1.y);
        Vector2 offset_y = new Vector2(value1.z, value1.w);
        float intensity = value2.x;
        float speed = value2.y;

        if (mask.x > 0.9)
        {
            mode = 1;
        }
        else if (mask.y > 0.9)
        {
            mode = 2;
        }
        else if (mask.z > 0.9)
        {
            mode = 3;
        }
        else if (mask.w > 0.9)
        {
            mode = 4;
        }
        mode = EditorGUILayout.Popup("Use Mask", mode, useMasks);
        speed = EditorGUILayout.FloatField("speed", speed);
        offset_x = EditorGUILayout.Vector2Field("horizontal offset", offset_x);
        offset_y = EditorGUILayout.Vector2Field("vertical offset", offset_y);
        intensity = EditorGUILayout.FloatField("intensity", intensity);
        if (EditorGUI.EndChangeCheck())
        {
            material.SetVector("_WaveValue1", new Vector4(offset_x.x, offset_x.y, offset_y.x, offset_y.y));
            material.SetVector("_WaveValue2", new Vector4(intensity, speed, 0, 0));
            material.SetVector("_WaveUseMask", useMasksVector[mode]);
            EditorUtility.SetDirty(material);
        }
        EditorGUI.indentLevel = 0;
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
            MaterialProperty prop = GetMaterialProperty(targets, "_Effect" + numberString + "Tex");
            TextureProperty(prop, "Texture(RGBA)", true);
            showUseMask(index);
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

        MaterialProperty mask1 = GetMaterialProperty(targets, "_MaskTex");
        TextureProperty(mask1, "Mask", false);
        showWave();

        for(int i = 0; i < 5; i++)
        {
            buildEffectPropertiesLayout(i);
        }
    }
}