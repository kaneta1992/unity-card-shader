using UnityEngine;
using System.Collections;
using UnityEditor;

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

    static bool[] showEffectSettings = { false, false, false, false, false };

    static string[] blendModes = new[] { "liner", "add", "sub", "mul" };
    static Vector4[] blendModesVector = new Vector4[] { new Vector4(1, 0, 0, 0), new Vector4(0, 1, 0, 0), new Vector4(0, 0, 1, 0), new Vector4(0, 0, 0, 1) };
    static int[] blendModeIndex = { 0, 0, 0, 0, 0 };

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
            blendModeIndex[index] = EditorGUILayout.Popup("Blend Mode", blendModeIndex[index], blendModes);
            EditorGUI.indentLevel = 0;

            if (EditorGUI.EndChangeCheck())
            {
                Vector4[] data = new Vector4[] {
                    blendModesVector[blendModeIndex[index]],
                    Vector4.zero,
                    Vector4.zero,
                    Vector4.zero,
                    Vector4.zero,
                    Vector4.zero,
                };
                material.SetVectorArray("_Effect" + numberString + "Data", data);
                EditorUtility.SetDirty(target);
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