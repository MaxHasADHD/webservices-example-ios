# Consuming Web Services in iOS

## In-lecture exercise

Implement the `execute` method of the struct `HTTPRequestHandler` to handle **GET** requests. To test your implementation run the app in the simulator or on device then click the 🔁 icon.

### Solution

Your finished method should look something like this:

```
    func execute( callback: @escaping (Result<Any>) -> Void) {
        guard let url = URL(string: path) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(.failure(error))
                return
            }
            guard let data = data else {
                callback(.failure(RequestError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    print("Received response: \(str)")
                }
                callback(.success(json))
            } catch (let e) {
                callback(.failure(e))
            }
        }
        
        task.resume()
    }
```

## Post-lecture exercise

Build upon your `execute` function to handle **POST** requests as well. You can see what the post takes in as arguments in the `ViewModel` class under the `toggleLED` method. You will need to add header values to and serialize the body data for URLRequest.

To test your implementation, run your app in simulator or on device and press the 💡 button. It should toggle the LED on your Particle Photon on and off.

Create a pull request with this updated code for review and feedback.