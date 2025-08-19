//
//  LoginModel.swift
//  
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation

// Login isteği için kullanılacak veri yapısı
struct LoginRequest: Codable {
    let username: String
    let password: String
}

// Login API'den dönecek cevabın veri yapısı
struct LoginResponse: Codable {
    let token: String
    let status: String
}
