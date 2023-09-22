//
//  GameViewController.swift
//  Super Plinko
//
//  Created by Artem Galiev on 15.09.2023.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    //UIKit
    let highScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let currentScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let buttonMenu: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: NameImage.menu.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let buttonPause: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: NameImage.pause.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var isPause: Bool = false
    var saveHighScore: Int = 0

    //Сцена
    var scnView: SCNView!
    var scnScene: SCNScene!

    //Камера
    var cameraNode: SCNNode!
    
    //Основные узлы
    var basicFloor: SCNNode!
    var newFloor: SCNNode!
    var winFloor: SCNNode!
    var loserFloor: SCNNode!
    var ball: SCNNode!
    var rotatingPlatform: SCNNode!
    var cone: SCNNode!
    var repellentWall: SCNNode!
    
    //Движение шарика
    var motion = MotionBall()
    var motionForce = SCNVector3(x: 0, y: 0, z: 0)
    
    var currentCollisium = SCNVector3(x: 0, y: 0, z: 0)
    
    //Уровень игры
    static var gameLevel: Int = 0
    var isLoser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        generateLevelGame()
        createBall()
        setupCamera()
        setupLight()
    }
}

//MARK: - Начальный настройки игры и моделей
extension GameViewController {
    
    //Настройка Scene
    private func setupScene() {
        let scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        scnView.delegate = self
        
        scnScene = SCNScene(named: "art.scnassets/Main.scn")
        scnView.scene = scnScene
        
        scnScene.physicsWorld.contactDelegate = self
        
        scnView.autoenablesDefaultLighting = true
        
        setupLabelesAndButton()
    }
    
    //Настройка камеры
    private func setupCamera() {
        cameraNode = scnScene.rootNode.childNode(withName: "camera", recursively: true)!
    }
    
    //Настройка света
    private func setupLight() {
        let firstLight = SCNNode()
        firstLight.light = SCNLight()
        firstLight.light?.type = SCNLight.LightType.directional
        firstLight.eulerAngles = SCNVector3Make(-45, 45, 0)
        scnScene.rootNode.addChildNode(firstLight)
        let secondLight = SCNNode()
        secondLight.light = SCNLight()
        secondLight.light?.type = SCNLight.LightType.directional
        secondLight.eulerAngles = SCNVector3Make(45, 45, 0)
        scnScene.rootNode.addChildNode(secondLight)
    }
    
    //MARK: - Создание основного пола
    private func createFloor(width: CGFloat, height: CGFloat, length: CGFloat, x: Float, y: Float, z: Float) {
        
        basicFloor = SCNNode()
        
        let basicFloorGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        basicFloor.geometry = basicFloorGeometry
        basicFloor.position = SCNVector3Make(x, y, z)
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = #colorLiteral(red: 0.001925094519, green: 0.08812785894, blue: 0.2028826475, alpha: 1)
        floorMaterial.diffuse.intensity = 1
        floorMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        floorMaterial.metalness.contents = SCNMaterial.LightingModel.blinn
        
        basicFloorGeometry.materials = [floorMaterial]
        
        basicFloor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basicFloor!, options: nil))
        basicFloor.physicsBody?.isAffectedByGravity = false
        
        scnScene.rootNode.addChildNode(basicFloor)
    }
    
    //MARK: - Создание шарика
    private func createBall() {
        ball = scnScene.rootNode.childNode(withName: "ball", recursively: true)

        ball.physicsBody?.categoryBitMask = BodyType.ball
        ball.physicsBody?.collisionBitMask = BodyType.cylinder
        ball.physicsBody?.contactTestBitMask = BodyType.cylinder
        ball.physicsBody?.collisionBitMask = BodyType.wall
        ball.physicsBody?.contactTestBitMask = BodyType.wall
        ball.physicsBody?.collisionBitMask = BodyType.win
        ball.physicsBody?.contactTestBitMask = BodyType.win
        ball.physicsBody?.collisionBitMask = BodyType.loser
        ball.physicsBody?.contactTestBitMask = BodyType.loser
//
    }
}

//MARK: - Генерация уровней
extension GameViewController {
    //Загрузка новых уровней
    private func generateLevelGame() {
        switch GameViewController.gameLevel {
        case 0: createMoreCylidner()
        case 1...10000: levelUp(level: GameViewController.gameLevel)
        default: print("error in generateLevelGame")
        }
    }
    
    //Увелечение сложности
    private func levelUp(level: Int) {
        var levelLong = 5
        switch GameViewController.gameLevel {
        case 1...5: levelLong = 5
        case 6...13: levelLong = 10
        case 14...25: levelLong = 25
        case 26...55: levelLong = 40
        case 56...10000: levelLong = level * 2
        default: levelLong = 20
        }

        //Длинна карты
        for i in 1...levelLong {
            createFloorWithObstacel(line: i)
        }
        createFloor(width: 9, height: 10, length: 9, x: 0, y: 0, z: 0)
        createFloor(width: 9 , height: 10, length: 1, x: 0, y: 0, z: Float(-3 + (((-levelLong) * 3) + (-2))))
        createFloor(width: 9 , height: 10, length: 1, x: 0, y: 0, z: Float(-3 + (((-levelLong) * 3) + (-4))))
        createFloor(width: 4 , height: 10, length: 1, x: -2.5, y: 0, z: Float(-3 + (((-levelLong) * 3) + (-3))))
        createFloor(width: 4 , height: 10, length: 1, x: 2.5, y: 0, z: Float(-3 + (((-levelLong) * 3) + (-3))))
        createWinBox(width: 1, height: 8, length: 1, x: 0, y: 0, z: Float(-3 + (((-levelLong) * 3) + (-3))))
    }
}

//MARK: - Борода плинко первый уровень
extension GameViewController {
    //Нулевой(стартовый уровень)
    private func createMoreCylidner() {
        createFloor(width: 17 , height: 10, length: 5, x: 0, y: 0, z: 4)
        createFloor(width: 17 , height: 10, length: 9, x: 0, y: 0, z: -4)
        createFloor(width: 8 , height: 10, length: 1, x: -4.5, y: 0, z: 1)
        createFloor(width: 8 , height: 10, length: 1, x: 4.5, y: 0, z: 1)
        createWinBox(width: 1, height: 8, length: 1, x: 0, y: 0, z: 1)
        var counter = 0
        for lineZ in -4...5 {
            if lineZ % 2 == 0 {
                for lineX in -counter...counter {
                    if lineX % 2 == 0 {
                        createCone(x: Float(lineX), z: Float(lineZ), radius: 0.2, height: 2)
                    } else {
                        createCone(x: Float(lineX), z: Float(lineZ) -  1, radius: 0.2, height: 2)
                    }
                }
                counter = counter + 2
            }
        }
        createRepellentWall(width: 17, length: 1, x: 0, z: 6)
    }
}

//MARK: - Создание новых элементов(препятствия)
extension GameViewController {
    //Создание 1/3 пола с препятсвием
    private func createFloorWithObstacel(line: Int) {
        let lineValue = Float(-3 + (-line * 3))
        
        let randomPositionWithObstacelFirst = Int.random(in: 1...3)
        var randomPositionWithObstacelSecond = Int.random(in: 1...3)
        var randomPositionWithObstacelThird = Int.random(in: 1...3)
        
        while randomPositionWithObstacelSecond == randomPositionWithObstacelFirst {
            randomPositionWithObstacelSecond = Int.random(in: 1...3)
        }
        
        while randomPositionWithObstacelThird == randomPositionWithObstacelFirst || randomPositionWithObstacelThird == randomPositionWithObstacelSecond{
            randomPositionWithObstacelThird = Int.random(in: 1...3)
        }
        
        switch GameViewController.gameLevel {
        case 1...3:
            createNewFloor(x: -3, z: lineValue)
            createNewFloor(x: 0, z: lineValue)
            createNewFloor(x: 3, z: lineValue)
            
            switch randomPositionWithObstacelFirst {
            case 1:
                generateCylinderHorizontal(x: -3, z: lineValue)
            case 2:
                generateCylinderHorizontal(x: 0, z: lineValue)
            case 3:
                generateCylinderHorizontal(x: 3, z: lineValue)
            default: print("error")
            }
            
            switch randomPositionWithObstacelSecond {
            case 1:
                generateCylinderHorizontal(x: -3, z: lineValue)
            case 2:
                generateCylinderHorizontal(x: 0, z: lineValue)
            case 3:
                generateCylinderHorizontal(x: 3, z: lineValue)

            default: print("error")
            }
            
        case 4...7:
            
            let randomValueFirst = Int.random(in: 1...3)
            var randomValueSecond = Int.random(in: 1...3)
            
            while randomValueSecond == randomValueFirst {
                randomValueSecond = Int.random(in: 1...3)
            }
            
            createNewFloor(x: -3, z: lineValue)
            createNewFloor(x: 0, z: lineValue)
            createNewFloor(x: 3, z: lineValue)
            
            switch randomPositionWithObstacelFirst {
            case 1:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                default: print("")
                }
            case 2:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                default: print("")
                }
            case 3:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                default: print("")
                }
            default: print("error")
            }
            
            switch randomPositionWithObstacelSecond {
            case 1:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                default: print("")
                }
            case 2:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                default: print("")
                }
            case 3:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                default: print("")
                }
            default: print("error")
            }
        case 8...11:
            let randomValueFirst = Int.random(in: 1...3)
            var randomValueSecond = Int.random(in: 1...3)
            
            while randomValueSecond == randomValueFirst {
                randomValueSecond = Int.random(in: 1...3)
            }
            
            switch randomPositionWithObstacelThird {
            case 1:
                createFloorWithHole(x: -3, z: lineValue)
                createNewFloor(x: 0, z: lineValue)
                createNewFloor(x: 3, z: lineValue)
            case 2:
                createNewFloor(x: -3, z: lineValue)
                createFloorWithHole(x: 0, z: lineValue)
                createNewFloor(x: 3, z: lineValue)
            case 3:
                createNewFloor(x: -3, z: lineValue)
                createNewFloor(x: 0, z: lineValue)
                createFloorWithHole(x: 3, z: lineValue)
            default: print("error")
            }
            
            switch randomPositionWithObstacelFirst {
            case 1:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                default: print("")
                }
            case 2:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                default: print("")
                }
            case 3:
                switch randomValueFirst {
                case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                default: print("")
                }
            default: print("error")
            }
            
            switch randomPositionWithObstacelSecond {
            case 1:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                default: print("")
                }
            case 2:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                default: print("")
                }
            case 3:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                default: print("")
                }
            default: print("error")
            }
        case 12...16:
            let randomValueFirst = Int.random(in: 1...3)
            var randomValueSecond = Int.random(in: 1...3)
            
            while randomValueSecond == randomValueFirst {
                randomValueSecond = Int.random(in: 1...3)
            }
            switch randomPositionWithObstacelThird {
            case 1:
                createFloorWithHole(x: -3, z: lineValue)
                createNewFloor(x: 0, z: lineValue)
                createNewFloor(x: 3, z: lineValue)
            case 2:
                createNewFloor(x: -3, z: lineValue)
                createFloorWithHole(x: 0, z: lineValue)
                createNewFloor(x: 3, z: lineValue)
            case 3:
                createNewFloor(x: -3, z: lineValue)
                createNewFloor(x: 0, z: lineValue)
                createFloorWithHole(x: 3, z: lineValue)
            default: print("error")
            }
            
            switch randomPositionWithObstacelFirst {
            case 1:
                createRotatingPlatform(x: -3, z: lineValue)
            case 2:
                createRotatingPlatform(x: 0, z: lineValue)
            case 3:
                createRotatingPlatform(x: 3, z: lineValue)
            default: print("error")
            }
            
            switch randomPositionWithObstacelSecond {
            case 1:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                default: print("")
                }
            case 2:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                default: print("")
                }
            case 3:
                switch randomValueSecond {
                case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                default: print("")
                }
            default: print("error")
            }
        case 17...10000:
            let randomValueFirst = Int.random(in: 1...3)
            var randomValueSecond = Int.random(in: 1...3)
            
            while randomValueSecond == randomValueFirst {
                randomValueSecond = Int.random(in: 1...3)
            }
            
            let randomRepaetThreePosition = Int.random(in: 1...10)
            let randomRepeatTwoPosition = Int.random(in: 1...5)
            let randomChoiceObstacel = Int.random(in: 1...2)
            if randomRepaetThreePosition == 7 {
                switch randomChoiceObstacel {
                case 1:
                    createFloorWithHole(x: -3, z: lineValue)
                    createFloorWithHole(x: 0, z: lineValue)
                    createFloorWithHole(x: 3, z: lineValue)
                case 2:
                    createNewFloor(x: -3, z: lineValue)
                    createNewFloor(x: 0, z: lineValue)
                    createNewFloor(x: 3, z: lineValue)

                    createRotatingPlatform(x: -3, z: lineValue)
                    createRotatingPlatform(x: 0, z: lineValue)
                    createRotatingPlatform(x: 3, z: lineValue)
                default: print("")
                }
            } else if randomRepeatTwoPosition == 4 {
                switch randomChoiceObstacel {
                case 1:
                    switch randomValueFirst {
                    case 1:
                        createFloorWithHole(x: -3, z: lineValue)
                        createFloorWithHole(x: 0, z: lineValue)
                        generateCylinderHorizontal(x: 3, z: lineValue)
                        
                        createNewFloor(x: 3, z: lineValue)
                    case 2:
                        generateCylinderHorizontal(x: -3, z: lineValue)
                        createFloorWithHole(x: 0, z: lineValue)
                        createFloorWithHole(x: 3, z: lineValue)
                        
                        createNewFloor(x: -3, z: lineValue)
                    case 3:
                        createFloorWithHole(x: -3, z: lineValue)
                        generateCylinderHorizontal(x: 0, z: lineValue)
                        createFloorWithHole(x: 3, z: lineValue)

                        createNewFloor(x: 0, z: lineValue)
                    default: print("")
                    }
                case 2:
                    switch randomValueFirst {
                    case 1:
                        createRotatingPlatform(x: -3, z: lineValue)
                        createRotatingPlatform(x: 0, z: lineValue)
                        generateCylinderHorizontal(x: 3, z: lineValue)
                        
                        createNewFloor(x: -3, z: lineValue)
                        createNewFloor(x: 0, z: lineValue)
                        createNewFloor(x: 3, z: lineValue)
                    case 2:
                        generateCylinderHorizontal(x: -3, z: lineValue)
                        createRotatingPlatform(x: 0, z: lineValue)
                        createRotatingPlatform(x: 3, z: lineValue)
                        
                        createNewFloor(x: -3, z: lineValue)
                        createNewFloor(x: 0, z: lineValue)
                        createNewFloor(x: 3, z: lineValue)
                    case 3:
                        createRotatingPlatform(x: -3, z: lineValue)
                        generateCylinderHorizontal(x: 0, z: lineValue)
                        createRotatingPlatform(x: 3, z: lineValue)
                        
                        createNewFloor(x: -3, z: lineValue)
                        createNewFloor(x: 0, z: lineValue)
                        createNewFloor(x: 3, z: lineValue)
                    default: print("")
                    }
                default: print("")
                }
            } else {
                
                switch randomPositionWithObstacelThird {
                case 1:
                    createFloorWithHole(x: -3, z: lineValue)
                    createNewFloor(x: 0, z: lineValue)
                    createNewFloor(x: 3, z: lineValue)
                case 2:
                    createNewFloor(x: -3, z: lineValue)
                    createFloorWithHole(x: 0, z: lineValue)
                    createNewFloor(x: 3, z: lineValue)
                case 3:
                    createNewFloor(x: -3, z: lineValue)
                    createNewFloor(x: 0, z: lineValue)
                    createFloorWithHole(x: 3, z: lineValue)
                default: print("error")
                }
                
                switch randomPositionWithObstacelFirst {
                case 1:
                    createRotatingPlatform(x: -3, z: lineValue)
                case 2:
                    createRotatingPlatform(x: 0, z: lineValue)
                case 3:
                    createRotatingPlatform(x: 3, z: lineValue)
                default: print("error")
                }
                
                switch randomPositionWithObstacelSecond {
                case 1:
                    switch randomValueSecond {
                    case 1: generateCylinderWithCornerRight(x: -3, z: lineValue)
                    case 2: generateCylinderWithCornerLeft(x: -3, z: lineValue)
                    case 3: generateCylinderHorizontal(x: -3, z: lineValue)
                    default: print("")
                    }
                case 2:
                    switch randomValueSecond {
                    case 1: generateCylinderWithCornerRight(x: 0, z: lineValue)
                    case 2: generateCylinderWithCornerLeft(x: 0, z: lineValue)
                    case 3: generateCylinderHorizontal(x: 0, z: lineValue)
                    default: print("")
                    }
                case 3:
                    switch randomValueSecond {
                    case 1: generateCylinderWithCornerRight(x: 3, z: lineValue)
                    case 2: generateCylinderWithCornerLeft(x: 3, z: lineValue)
                    case 3: generateCylinderHorizontal(x: 3, z: lineValue)
                    default: print("")
                    }
                default: print("error")
                }
            }
        default: print("")
        }
        
        
    }
    
//MARK: - Генерация цилиндров
    //Горизонтальное расположение
    private func generateCylinderHorizontal(x: Float, z: Float) {
        createCone(x: x - 1, z: z, radius: 0.2, height: 2)
        createCone(x: x, z: z, radius: 0.2, height: 2)
        createCone(x: x + 1, z: z, radius: 0.2, height: 2)
    }
    
    //Наклон вправо
    private func generateCylinderWithCornerRight(x: Float, z: Float) {
        createCone(x: x + 1, z: z - 1, radius: 0.2, height: 2)
        createCone(x: x, z: z, radius: 0.2, height: 2)
        createCone(x: x + 0.5, z: z - 0.5, radius: 0.2, height: 2)
        createCone(x: x - 0.5, z: z + 0.5, radius: 0.2, height: 2)
    }
    
    //Наклон влево
    private func generateCylinderWithCornerLeft(x: Float, z: Float) {
        createCone(x: x - 1, z: z - 1, radius: 0.2, height: 2)
        createCone(x: x, z: z, radius: 0.2, height: 2)
        createCone(x: x - 0.5, z: z - 0.5, radius: 0.2, height: 2)
        createCone(x: x + 0.5, z: z + 0.5, radius: 0.2, height: 2)
    }
    
//MARK: - Победный бокс
    private func createWinBox(width: CGFloat, height: CGFloat, length: CGFloat, x: Float, y: Float, z: Float) {
        winFloor = SCNNode()
        //17 10 15
        let basicFloorGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        winFloor.geometry = basicFloorGeometry
        winFloor.position = SCNVector3Make(x, y, z)
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = #colorLiteral(red: 0, green: 0.6549065113, blue: 0, alpha: 1)
        floorMaterial.diffuse.intensity = 1
        floorMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        floorMaterial.metalness.contents = SCNMaterial.LightingModel.blinn
        
        basicFloorGeometry.materials = [floorMaterial]
        
        winFloor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: winFloor!, options: nil))
        winFloor.physicsBody?.isAffectedByGravity = false
        winFloor.physicsBody?.categoryBitMask = BodyType.win
        winFloor.physicsBody?.collisionBitMask = BodyType.ball
        winFloor.physicsBody?.contactTestBitMask = BodyType.ball
        
        scnScene.rootNode.addChildNode(winFloor)
    }
    
    //MARK: - Проигрышный бокс
    private func createLoserBox(width: CGFloat, height: CGFloat, length: CGFloat, x: Float, y: Float, z: Float) {
        loserFloor = SCNNode()
        
        let basicFloorGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        loserFloor.geometry = basicFloorGeometry
        loserFloor.position = SCNVector3Make(x, y, z)
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        floorMaterial.diffuse.intensity = 1
        floorMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        floorMaterial.metalness.contents = SCNMaterial.LightingModel.blinn
        
        basicFloorGeometry.materials = [floorMaterial]
        
        loserFloor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: loserFloor!, options: nil))
        loserFloor.physicsBody?.isAffectedByGravity = false
        loserFloor.physicsBody?.categoryBitMask = BodyType.loser
        loserFloor.physicsBody?.collisionBitMask = BodyType.ball
        loserFloor.physicsBody?.contactTestBitMask = BodyType.ball
        
        scnScene.rootNode.addChildNode(loserFloor)
    }
    
//MARK: - Элемент пола 1/3 от всей полоски по оси z
    private func createNewFloor(x: Float, z: Float) {
        newFloor = SCNNode()

        let basicFloorGeometry = SCNBox(width: 3, height: 10, length: 3, chamferRadius: 0)
        newFloor.geometry = basicFloorGeometry
        newFloor.position = SCNVector3Make(x, 0, z)

        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = #colorLiteral(red: 0.001925094519, green: 0.08812785894, blue: 0.2028826475, alpha: 1)
        floorMaterial.diffuse.intensity = 1
        floorMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        floorMaterial.metalness.contents = SCNMaterial.LightingModel.blinn

        basicFloorGeometry.materials = [floorMaterial]

        newFloor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: newFloor!, options: nil))
        newFloor.physicsBody?.isAffectedByGravity = false

        scnScene.rootNode.addChildNode(newFloor)
    }
    
    //MARK: - Крутящаяся платформа
    private func createRotatingPlatform(x: Float, z: Float) {
        rotatingPlatform = SCNNode()
        let rotatingPlatformGeometry = SCNCylinder(radius: 0.15, height: 2.7)
        rotatingPlatform.geometry = rotatingPlatformGeometry
        rotatingPlatform.position = SCNVector3(x: x, y: 5.3, z: z)
        rotatingPlatform.eulerAngles = SCNVector3(x: 0, y: 0, z: 80.1)
        
        let rotatingPlatformMaterial = SCNMaterial()
        rotatingPlatformMaterial.diffuse.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rotatingPlatformMaterial.diffuse.intensity = 1
        rotatingPlatformMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rotatingPlatformMaterial.metalness.contents = SCNMaterial.LightingModel.physicallyBased

        rotatingPlatformGeometry.materials = [rotatingPlatformMaterial]

        rotatingPlatform.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: rotatingPlatform!, options: nil))
        
        scnScene.rootNode.addChildNode(rotatingPlatform)
        let isByTheHourr = Bool.random()
        var direction = -2
        if isByTheHourr == true {
            direction = -2
        } else {
            direction = 2
        }
        
        var durationPlatform: Double = 2
        switch GameViewController.gameLevel {
        case 1...14: durationPlatform = 2
        case 15...25: durationPlatform = 1.5
        case 26...50: durationPlatform = 1.25
        case 51...10000: durationPlatform = 1
        default: durationPlatform = 2
        }
        
        let rotate = SCNAction.rotate(by: CGFloat(Double.pi * Double(direction)), around: SCNVector3Make(0, 0.5, 0), duration: durationPlatform)
        rotatingPlatform.runAction(SCNAction.repeatForever(rotate))
        createCone(x: x, z: z, radius: 0.15, height: 0.5)
    }
    
    //MARK: - Создание цилиндра
    private func createCone(x: Float, z: Float, radius: CGFloat, height: CGFloat) {
        cone = SCNNode()
        let coneGeometry = SCNCylinder(radius: radius, height: height)
        cone.geometry = coneGeometry
        cone.position = SCNVector3(x: x, y: 5, z: z)
        let coneMaterial = SCNMaterial()
        coneMaterial.diffuse.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        coneMaterial.diffuse.intensity = 1
        coneMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        coneMaterial.metalness.contents = SCNMaterial.LightingModel.physicallyBased

        coneGeometry.materials = [coneMaterial]

        cone.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: cone!, options: nil))
        cone.physicsBody?.categoryBitMask = BodyType.cylinder
        cone.physicsBody?.collisionBitMask = BodyType.ball
        cone.physicsBody?.contactTestBitMask = BodyType.ball
        cone.physicsBody?.isAffectedByGravity = false
        
        scnScene.rootNode.addChildNode(cone)

    }
    
    //MARK: - 1/3 пола с дыркой
    private func createFloorWithHole(x: Float, z: Float) {
        //3 10 3
        createFloor(width: 1, height: 10, length: 3, x: x + 1, y: 0, z: z)
        createFloor(width: 1, height: 10, length: 1, x: x, y: 0, z: z - 1)
        createFloor(width: 1, height: 10, length: 1, x: x, y: 0, z: z + 1)
        createFloor(width: 1, height: 10, length: 3, x: x - 1, y: 0, z: z)
        createLoserBox(width: 1, height: 8, length: 1, x: x, y: 0, z: z)
    }
    
    //MARK: - Отталкивающая стенка
    private func createRepellentWall(width: CGFloat, length: CGFloat, x: Float, z: Float) {
        repellentWall = SCNNode()

        let repellentWallGeometry = SCNBox(width: width, height: 1, length: length, chamferRadius: 0)
        repellentWall.geometry = repellentWallGeometry
        repellentWall.position = SCNVector3Make(x, 5.5, z)

        let repellentWallMaterial = SCNMaterial()
        repellentWallMaterial.diffuse.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        repellentWallMaterial.diffuse.intensity = 1
        repellentWallMaterial.normal.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        repellentWallMaterial.metalness.contents = SCNMaterial.LightingModel.blinn

        repellentWallGeometry.materials = [repellentWallMaterial]

        repellentWall.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: repellentWall!, options: nil))
        repellentWall.physicsBody?.isAffectedByGravity = false
        
        repellentWall.physicsBody?.categoryBitMask = BodyType.wall
        repellentWall.physicsBody?.collisionBitMask = BodyType.ball
        repellentWall.physicsBody?.contactTestBitMask = BodyType.ball

        scnScene.rootNode.addChildNode(repellentWall)
        
    }
}

//MARK: - Управление шариком + камера
extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let ballN = ball.presentation
        let ballPosition = ballN.position

        let targetPosition = SCNVector3(x: ballPosition.x , y: ballPosition.y + 15, z:ballPosition.z + 5 )
        var cameraPosition = cameraNode.position

        let camDamping: Float = 0.1

        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping

        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        cameraNode.position = cameraPosition
        
        motion.getAccelerometrData { (x, y, z) in
            self.motionForce = SCNVector3(x: x * 0.05, y:0, z: (y + 0.3) * -0.05)
        }
        
        ball.physicsBody?.velocity += motionForce
        let wait = SCNAction.wait(duration: 3)
        let ballFall = SCNAction.run { node in
            if self.ball.presentation.position.y < 0 || self.isLoser == true {
                self.ball.physicsBody?.velocity = SCNVector3(x: 0, y: 0, z: 0)
                self.ball.position = SCNVector3Make(0, 10, -3.5)
                self.isLoser = false
            }
        }
        
        let sequance = SCNAction.sequence([wait, ballFall])
        ball.runAction(sequance)
        

    }
}

//MARK: - Обработка столкновений шарика с различными объектами
extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
 
        if nodeA.physicsBody?.categoryBitMask == BodyType.wall && nodeB.physicsBody?.categoryBitMask == BodyType.ball {
            self.ball.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: 8), asImpulse: true)
        } else if nodeA.physicsBody?.categoryBitMask == BodyType.ball && nodeB.physicsBody?.categoryBitMask == BodyType.wall {
            ball.physicsBody?.applyForce(SCNVector3(x: 0.1, y: 0, z: 8), asImpulse: false)
        }
        if nodeA.physicsBody?.categoryBitMask == BodyType.win && nodeB.physicsBody?.categoryBitMask == BodyType.ball {
            DispatchQueue.main.async {
                let vc = WinViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }

        } else if nodeA.physicsBody?.categoryBitMask == BodyType.ball && nodeB.physicsBody?.categoryBitMask == BodyType.win {
            DispatchQueue.main.async {
                let vc = WinViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        
        if nodeA.physicsBody?.categoryBitMask == BodyType.loser && nodeB.physicsBody?.categoryBitMask == BodyType.ball {
            isLoser = true
        } else if nodeA.physicsBody?.categoryBitMask == BodyType.ball && nodeB.physicsBody?.categoryBitMask == BodyType.loser {
            isLoser = true
        }
    }
}

//MARK: - Сохранение рекорда
extension GameViewController {
    private func highScoreCounter() {
        saveHighScore = UserDefaults.standard.integer(forKey: "saveScore")
        if saveHighScore < GameViewController.gameLevel - 1  {
            UserDefaults.standard.set(GameViewController.gameLevel - 1, forKey: "saveScore")
            saveHighScore = GameViewController.gameLevel - 1
        }
    }
}

//MARK: - Настройка Label и Button
extension GameViewController {
    private func setupLabelesAndButton() {
        highScoreCounter()

        highScoreLabel.text = "High score - \(saveHighScore)"

        self.view.addSubview(highScoreLabel)
        highScoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        highScoreLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        highScoreLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        highScoreLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        currentScoreLabel.text = "Level - " + String(GameViewController.gameLevel)
        
        self.view.addSubview(currentScoreLabel)
        currentScoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        currentScoreLabel.topAnchor.constraint(equalTo: highScoreLabel.bottomAnchor, constant: 8).isActive = true
        currentScoreLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        currentScoreLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        buttonMenu.addTarget(self, action: #selector(actionButtonMenu), for: .touchUpInside)

        self.view.addSubview(buttonMenu)
        
        buttonMenu.widthAnchor.constraint(equalToConstant: 50).isActive = true
        buttonMenu.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonMenu.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        buttonMenu.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        buttonPause.addTarget(self, action: #selector(actionButtonPause), for: .touchUpInside)
        
        self.view.addSubview(buttonPause)
        
        buttonPause.widthAnchor.constraint(equalToConstant: 50).isActive = true
        buttonPause.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonPause.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        buttonPause.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
    }
    
    @objc func actionButtonMenu() {
        GameViewController.gameLevel = 0
        let vc = MenuViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true) 
    }
    
    @objc func actionButtonPause() {
        isPause = !isPause
        switch isPause {
        case true:
            scnScene.isPaused = true
            buttonPause.setImage(UIImage(named: NameImage.play.rawValue), for: .normal)
        case false:
            scnScene.isPaused = false
            buttonPause.setImage(UIImage(named: NameImage.pause.rawValue), for: .normal)
        }
    }
}
