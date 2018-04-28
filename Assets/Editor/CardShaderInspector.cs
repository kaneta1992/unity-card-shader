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

        MaterialProperty effect1 = GetMaterialProperty(targets, "_Blend1Tex");
        TextureProperty(effect1, "Effect1", true);

        MaterialProperty effect2 = GetMaterialProperty(targets, "_Blend2Tex");
        TextureProperty(effect2, "Effect2", true);

        MaterialProperty effect3 = GetMaterialProperty(targets, "_Blend3Tex");
        TextureProperty(effect3, "Effect3", true);

        MaterialProperty effect4 = GetMaterialProperty(targets, "_Blend4Tex");
        TextureProperty(effect4, "Effect4", true);

        if (EditorGUI.EndChangeCheck())
        {
        }
    }
}