//
//  URLProviderProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol URLProviderProtocol {
    func getURLForRecording() throws -> URL
}
