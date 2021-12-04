//
//  ViewController.swift
//  AnimationDemo
//
//  Created by Victor Engel on 12/4/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var board: UIView!
    
    var uiSetupFinished = false
    var tileSize : CGFloat = 0
    var token = UIView()
    let startingTag = 1000
    let finalTag = 1000 + 40 * 40 - 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        // Set up a 40 by 40 board
        tileSize = board.bounds.size.width / 40 // For this demo, the board is square, to make things simple.
        if uiSetupFinished {
            updateFrames() // Not using constraints
            return
        }
        var frame = CGRect(x: 0, y: 0, width: tileSize, height: tileSize)
        var tag = startingTag
        for row in 0..<40 {
            for col in 0..<40 {
                let origin = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize)
                frame.origin = origin
                let v = UIView(frame: frame)
                v.tag = tag
                tag += 1
                v.backgroundColor = UIColor.init(white: CGFloat.random(in: 0...1), alpha: 1)
                board.addSubview(v)
            }
        }
        token = UIView(frame: frame)
        token.backgroundColor = .yellow
        token.layer.borderWidth = 2
        token.layer.borderColor = UIColor.black.cgColor
        token.layer.cornerRadius = tileSize / 2
        placeToken()
        uiSetupFinished = true
    }
    
    func placeToken() {
        let tag = Int.random(in: startingTag...finalTag)
        if let v = board.viewWithTag(tag) {
            let center = v.center
            token.center = center
            board.addSubview(token)
        }
    }
    
    func updateFrames() {
        var frame = CGRect(x: 0, y: 0, width: tileSize, height: tileSize)
        for sv in board.subviews {
            let tag = sv.tag
            if tag >= startingTag {
                let (col,row) = coordFromTag(tag)
                let origin = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize)
                frame.origin = origin
                sv.frame = frame
            }
        }
        token.frame.size = CGSize(width: tileSize, height: tileSize)
        token.layer.cornerRadius = tileSize / 2
    }
    
    func coordFromTag(_ tag:Int) -> (Int,Int) {
        let index = tag - startingTag
        let row = index / 40
        let col = index % 40
        return (col,row)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Run backward or forward when the user presses a left or right arrow key.
        var direction = CGPoint(x: 0, y: 0)
        for press in presses {
            guard let key = press.key else { continue }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                direction.x = -1
            } else
            if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                direction.x = 1
            } else
            if key.charactersIgnoringModifiers == UIKeyCommand.inputUpArrow {
                direction.y = -1
            } else
            if key.charactersIgnoringModifiers == UIKeyCommand.inputDownArrow {
                direction.y = 1
            }
        }
        moveToken(direction)
    }
    
    func moveToken(_ direction:CGPoint) {
        let delta = CGPoint(x: direction.x * tileSize, y: direction.y * tileSize)
        let p = token.center
        let newP = CGPoint(x: p.x + delta.x, y: p.y + delta.y)
        if board.bounds.contains(newP) {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                self.token.center = newP
            }
            animator.startAnimation()
            animateLabelTowardBoardCenter()
        }
    }
    
    func animateLabelTowardBoardCenter() {
        let text = "(\(token.center.x),\(token.center.y))"
        let label = UILabel()
        label.text = text
        label.sizeToFit()
        let frame = CGRect(x: 0, y: 0, width: label.frame.size.width + 8, height: label.frame.size.height + 8)
        let labelHolder = UIView(frame: frame)
        labelHolder.backgroundColor = .white
        labelHolder.layer.borderWidth = 2
        labelHolder.layer.borderColor = UIColor.black.cgColor
        labelHolder.addSubview(label)
        label.frame.origin = CGPoint(x: 4, y: 4)
        label.textColor = .black
        labelHolder.center = token.center
        board.addSubview(labelHolder)
        let destination = CGPoint(x: board.bounds.midX, y: board.bounds.midY)
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            labelHolder.center = destination
            labelHolder.alpha = 0
        }
        // This completion block causes the stutter. Comment this out and the stutter is gone. Or, use an empty completion block.
        animator.addCompletion { (position) in
            label.removeFromSuperview()
            labelHolder.removeFromSuperview()
        }
        animator.startAnimation()

    }

}

