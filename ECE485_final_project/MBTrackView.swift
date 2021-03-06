//
//  MBTrackView.swift
//  ECE485_final_project
//
//  Created by Davis Gossage on 12/4/15.
//  Copyright © 2015 Davis Gossage. All rights reserved.
//

import Cocoa

protocol MBTrackViewClickDelegate{
    func trackSelected(sender:MBTrackView)
}

class MBTrackView: NSView, NSSplitViewDelegate, MBTrackHeaderViewClickDelegate {
    
    var delegate : MBTrackViewClickDelegate?
    
    @IBOutlet var trackNumLabel : NSTextField?
    @IBOutlet var view : NSView?
    @IBOutlet var splitView : NSSplitView?
    @IBOutlet var headerView : MBTrackHeaderView?
    @IBOutlet var volume : NSTextField?
    var borderColor : NSColor?
    var selectedBorderColor : NSColor?
    var selected : Bool!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit(){
        selected = false
        NSBundle.mainBundle().loadNibNamed("MBTrackView", owner: self, topLevelObjects: nil)
        
        setContentFrame()
        
        headerView?.clickDelegate = self
        
        self.wantsLayer = true
        self.layer?.cornerRadius = 5.0
        
        self.addSubview(self.view!)
    }
    
    override func setFrameSize(newSize: NSSize) {
        super.setFrameSize(newSize)
        setContentFrame()
    }
    
    func setContentFrame(){
        let contentFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)
        self.view!.frame = contentFrame
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        self.layer?.borderColor = selected! ? selectedBorderColor!.CGColor : borderColor!.CGColor
        self.layer?.borderWidth = 1.0
    }
    
    func setSelected(selected : Bool) {
        self.headerView?.setSelected(selected)
        self.selected = selected
        if (selected){
            self.layer?.borderColor = selectedBorderColor!.CGColor
        }
        else{
            self.layer?.borderColor = borderColor!.CGColor
        }
    }
    
    //MARK: adding notes
    
    func addNoteBlock(note: MBNote){
        let noteView = MBNoteView(frame: NSRect(x: 0, y: 0, width: 50, height: 70),note: note)
        splitView?.insertArrangedSubview(noteView, atIndex: splitView!.subviews.count-1)
        splitView?.setHoldingPriority(NSLayoutPriorityDefaultHigh, forSubviewAtIndex: splitView!.subviews.count-1)
        if (splitView!.subviews.count-3 > 0){
            let noteViewForLocking = splitView!.subviews[splitView!.subviews.count-2] as! MBNoteView
            noteViewForLocking.widthLocked = true
        }
    }
    
    func rebuildWithNotes(notes: [MBNote]){
        for view in splitView!.subviews{
            if view.isKindOfClass(MBNoteView){
                view.removeFromSuperview()
            }
        }
        for note in notes{
            let noteView = MBNoteView(frame: NSRect(x: 0, y: 0, width: 50*note.duration, height: 70),note: note)
            splitView?.insertArrangedSubview(noteView, atIndex: splitView!.subviews.count-1)
            splitView?.setHoldingPriority(NSLayoutPriorityDefaultHigh, forSubviewAtIndex: splitView!.subviews.count-1)
            if (splitView!.subviews.count-3 > 0){
                let noteViewForLocking = splitView!.subviews[splitView!.subviews.count-2] as! MBNoteView
                noteViewForLocking.widthLocked = true
            }
            noteView.updateContent()
        }
    }
    
    //MARK: output
    
    func noteArray() -> [MBNote]{
        var notes : [MBNote] = []
        for view in splitView!.subviews{
            if (view.isKindOfClass(MBNoteView)){
                let noteView = view as! MBNoteView
                notes.append(noteView.note!)
            }
        }
        return notes
    }
    
    func playNotes(){
        MBDataModel.sharedInstance.playNoteArray(noteArray(),amplitude: adjustedVolume())
    }
    
    func adjustedVolume() -> Float{
        return pow(Float(volume!.stringValue)!,2.0)/10000
    }
    
    //MARK: split view delegate
    
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return true
    }
    
    func splitView(splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if (dividerIndex != 0){
            //round to nearest 50
            let widthRounded = 50 * Int(round(proposedPosition / 50.0))+24
            return CGFloat(widthRounded)
        }
        return proposedPosition
    }
    
    func splitView(splitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        //hide the divider of the track header view
        return dividerIndex == 0
    }
    
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if (dividerIndex == 0){
            return 70;
        }
        return CGFloat.max
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if (dividerIndex == 0){
            return 70;
        }
        else{
            return 50;
        }
    }
    
    //MARK: header view delegate
    
    func headerViewClicked() {
        if (selected!){
            //play
            playNotes()
        }
        else{
            delegate?.trackSelected(self)
        }
    }
    
}
