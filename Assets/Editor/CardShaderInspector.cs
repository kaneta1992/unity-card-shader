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

    private int showBlendMode(int index)
    {
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
        return EditorGUILayout.Popup("Blend Mode", mode, blendModes);
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
            int mode = showBlendMode(index);
            EditorGUI.indentLevel = 0;

            if (EditorGUI.EndChangeCheck())
            {
                Vector4 data = blendModesVector[mode];
                material.SetVector("_Effect" + numberString + "BlendMode", data);
                Debug.Log(data);
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