/// Copyright (c) 2024 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreImage

class ContentViewModel: ObservableObject {
  // 1
  @Published var frame: CGImage?
  // 2
  private let frameManager = FrameManager.shared
  @Published var error: Error?
  private let cameraManager = CameraManager.shared
  var comicFilter = false
  var monoFilter = false
  var crystalFilter = false
  private let context = CIContext()

  init() {
    setupSubscriptions()
  }
  // 3
  func setupSubscriptions() {
    // 1
    cameraManager.$error
      // 2
      .receive(on: RunLoop.main)
      // 3
      .map { $0 }
      // 4
      .assign(to: &$error)

//    // 1
//    frameManager.$current
//      // 2
//      .receive(on: RunLoop.main)
//      // 3
//      .compactMap { buffer in
//        return CGImage.create(from: buffer)
//      }
//      // 4
//      .assign(to: &$frame)
    frameManager.$current
      .receive(on: RunLoop.main)
      .compactMap { $0 }
      .compactMap { buffer in
        // 1
        guard let image = CGImage.create(from: buffer) else {
          return nil
        }
        // 2
        var ciImage = CIImage(cgImage: image)
        // 3
        if self.comicFilter {
          ciImage = ciImage.applyingFilter("CIComicEffect")
        }
        if self.monoFilter {
          ciImage = ciImage.applyingFilter("CIPhotoEffectNoir")
        }
        if self.crystalFilter {
          ciImage = ciImage.applyingFilter("CICrystallize")
        }
        // 4
        return self.context.createCGImage(ciImage, from: ciImage.extent)
      }
      .assign(to: &$frame)
  }
}
