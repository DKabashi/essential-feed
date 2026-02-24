//
//  ReoteFeedLoaderTypes.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public typealias RemoteFeedLoaderResult = Result<(Data, HTTPURLResponse), RemoteFeedLoader.APIError>
