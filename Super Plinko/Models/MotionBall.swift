//
//  MotionBall.swift
//  Super Plinko
//
//  Created by Artem Galiev on 18.09.2023.
//

import Foundation
import CoreMotion

class MotionBall {
    
    let motionManager = CMMotionManager()
    
    init() {
    }
    
    func getAccelerometrData(interval: TimeInterval = 0.1, motionDataResult: ((_ x: Float, _ y: Float, _ z: Float) -> ())? ) {
        
        if motionManager.isAccelerometerAvailable {
            
            motionManager.accelerometerUpdateInterval = interval
            
            motionManager.startAccelerometerUpdates(to: OperationQueue()) { data, error in
                if motionDataResult != nil {
                    motionDataResult!(Float(data!.acceleration.x),Float(data!.acceleration.y),Float(data!.acceleration.z))
                }
            }
        }
    }
}
