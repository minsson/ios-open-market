//
//  MockURLSessionTests.swift
//  OpenMarketTests
//
//  Created by cathy, mmim.
//

import XCTest
@testable import OpenMarket

final class MockURLSessionTests: XCTestCase {
  var sut: HttpProvider!
  let mockData = MockData().loadData()!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)
    sut = HttpProvider(session: urlSession)
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    sut = nil
  }

  func test_mockData_pageNumber은_1이다() {
    //given
    MockURLProtocol.requestHandler = { request in
      let exampleData = self.mockData
      let response = HTTPURLResponse(url: request.url!,
                                     statusCode: 200,
                                     httpVersion: "2.0",
                                     headerFields: ["Content-Type" : "application/json"])!
      return (response, exampleData)
    }
    let expectation = XCTestExpectation(description: "response data")
    let requirements = HttpRequirements(endpoint: .page(pageNumber: 1, itemsPerPage: 20))
    //when
    sut.execute(requirements) { data in
      // then
      switch data {
      case .success(let data):
        guard let products = try? JSONDecoder().decode(PageInformation.self, from: data) else {
          return
        }
        XCTAssertEqual(products.pageNumber, 1)
      case .failure(let error):
        print(error)
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }
  
  func test_mockData_pages의_count는_10이다() {
    //given
    MockURLProtocol.requestHandler = { request in
      let exampleData = self.mockData
      let response = HTTPURLResponse(url: request.url!,
                                     statusCode: 200,
                                     httpVersion: "2.0",
                                     headerFields: ["Content-Type" : "application/json"])!
      return (response, exampleData)
    }
    let expectation = XCTestExpectation(description: "response data")
    let requirements = HttpRequirements(endpoint: .page(pageNumber: 1, itemsPerPage: 20))
    //when
    sut.execute(requirements) { data in
      // then
      switch data {
      case .success(let data):
        guard let products = try? JSONDecoder().decode(PageInformation.self, from: data) else {
          return
        }
        XCTAssertEqual(products.pages.count, 10)
      case .failure(let error):
        print(error)
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }
  
  func test_mockData_pages의_첫번째_index_id는_20이다() {
    //given
    MockURLProtocol.requestHandler = { request in
      let exampleData = self.mockData
      let response = HTTPURLResponse(url: request.url!,
                                     statusCode: 200,
                                     httpVersion: "2.0",
                                     headerFields: ["Content-Type" : "application/json"])!
      return (response, exampleData)
    }
    let expectation = XCTestExpectation(description: "response data")
    let requirements = HttpRequirements(endpoint: .page(pageNumber: 1, itemsPerPage: 20))
    //when
    sut.execute(requirements) { data in
      // then
      switch data {
      case .success(let data):
        guard let products = try? JSONDecoder().decode(PageInformation.self, from: data) else {
          return
        }
        XCTAssertEqual(products.pages.first?.id, 20)
      case .failure(let error):
        print(error)
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }
}
