//
//  EditorViewController+Text.swift
//  HXPHPicker
//
//  Created by Silence on 2023/5/17.
//

import UIKit

extension EditorViewController: EditorStickerTextViewControllerDelegate {
    func stickerTextViewController(_ controller: EditorStickerTextViewController, didFinish stickerText: EditorStickerText) {
        deselectedDrawTool()
        if let tool = selectedTool,
           tool.type == .graffiti || tool.type == .graffiti {
            selectedTool = nil
        }
        editorView.addSticker(stickerText)
        checkSelectedTool()
        checkFinishButtonState()
    }
    
    func stickerTextViewController(
        _ controller: EditorStickerTextViewController,
        didFinishUpdate stickerText: EditorStickerText
    ) {
        deselectedDrawTool()
        if let tool = selectedTool,
           tool.type == .graffiti || tool.type == .graffiti {
            selectedTool = nil
        }
        editorView.updateSticker(stickerText)
        checkSelectedTool()
    }
}
