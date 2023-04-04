import Foundation
import Combine
import CoreMotion

class MotionManager: ObservableObject {

    private var motionManager: CMMotionManager

    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0


    init(fps: Double) {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1 / fps
        motionManager.startDeviceMotionUpdates(to: .main) { [self] (data, error) in
            guard let data = data else {
                print("Error: \(error!)")
                return
            }

            self.pitch = data.attitude.pitch
            self.yaw = data.attitude.yaw
            self.roll = data.attitude.roll
        }

    }
}

let globalMotionManager = MotionManager(fps: 1)
