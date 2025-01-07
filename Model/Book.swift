//
//  Book.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 23.11.2024.
//

import Foundation

struct BooksResponse: Codable {
    let kind: String
    let totalItems: Int
    let items: [BookItem]
}

struct BookItem: Codable, Identifiable {
    let kind: String
    let id: String
    let etag: String
    let selfLink: String
    var notes: String?
    var bookmarkPage: Int?
    var readingTime: Int?
    var timestamp: Date?
    let volumeInfo: VolumeInfo
    let saleInfo: SaleInfo?
    let accessInfo: AccessInfo
}

struct VolumeInfo: Codable {
    let title: String
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let pageCount: Int?
    let printType: String
    let categories: [String]?
    let imageLinks: ImageLinks?
    let language: String?
    let averageRating: Double?
    let ratingsCount: Int?
    let previewLink: String
    let infoLink: String
    let canonicalVolumeLink: String
}


struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}


struct ImageLinks: Codable {
    let smallThumbnail: String
    let thumbnail: String
}


struct SaleInfo: Codable {
    let country: String
    let saleability: String
    let isEbook: Bool
    let listPrice: Price?
    let retailPrice: Price?
}


struct Price: Codable {
    let amount: Double
    let currencyCode: String
}


struct AccessInfo: Codable {
    let country: String
    let viewability: String
    let embeddable: Bool
    let publicDomain: Bool
    let epub: FileAvailability
    let pdf: FileAvailability
    let webReaderLink: String
}


struct FileAvailability: Codable {
    let isAvailable: Bool
    let acsTokenLink: String?
}
