//
//  Alamofire+Codable.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    static func decodableSerializer<T: Decodable>(decoder: JSONDecoder) -> DataResponseSerializer<T> {
        DataResponseSerializer<T> { _, response, data, error in
            if let error = error {
                return .failure(error)
            }
            let result = Request.serializeResponseJSON(options: [], response: response, data: data, error: error)
            switch result {
                case .success(let json):
                    do {
                        let data = try JSONSerialization.data(withJSONObject: json)
                        let object = try decoder.decode(T.self, from: data)
                        return .success(object)
                    } catch {
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
            }

        }
    }

    @discardableResult
    func responseDecodable<T: Decodable>(decoder: JSONDecoder = JSONDecoder(), completion: @escaping (DataResponse<T>) -> Void) -> Self {
        response(queue: nil, responseSerializer: DataRequest.decodableSerializer(decoder: decoder), completionHandler: completion)
    }
}
