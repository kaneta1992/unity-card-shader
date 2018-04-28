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

    private void buildEffectPropertiesLayout(int index)
    {
        string numberString = (index + 1).ToString();
        showEffectSettings[index] = EditorGUILayout.Foldout(showEffectSettings[index], "Effect" + numberString);
        if (showEffectSettings[index])
        {

            // 1段下げてUIを表示
            EditorGUI.indentLevel = 1;
            MaterialProperty prop = GetMaterialProperty(targets, "_Blend" + numberString + "Tex");
            TextureProperty(prop, "Texture(RGBA)", true);
            EditorGUI.indentLevel = 0;
        }
    }

    // Inspectorに表示される内容
    public override void OnInspectorGUI()
    {
        // マテリアルを閉じた時に非表示にする
        if (isVisible == false) { return; }
        EditorGUI.BeginChangeCheck();

        MaterialProperty mask1 = GetMaterialProperty(targets, "_Mask1Tex");
        TextureProperty(mask1, "Mask1", false);

        MaterialProperty mask2 = GetMaterialProperty(targets, "_Mask2Tex");
        TextureProperty(mask2, "Mask2", false);

        for(int i = 0; i < 5; i++)
        {
            buildEffectPropertiesLayout(i);
        }


        if (EditorGUI.EndChangeCheck())
        {
        }
    }
}