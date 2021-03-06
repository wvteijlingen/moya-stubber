#if canImport(UIKit)

import UIKit

class EndpointDetailsViewController: UITableViewController {
  private let stubber: MoyaStubber
  private let endpoint: StubbableEndpoint

  private var customizedStubs: [Stub] {
    endpoint.availableStubs.filter { !$0.isGeneric }
  }

  private var genericStubs: [Stub] {
    endpoint.availableStubs.filter { $0.isGeneric }
  }

  init(stubber: MoyaStubber, endpoint: StubbableEndpoint) {
    self.stubber = stubber
    self.endpoint = endpoint
    super.init(style: .grouped)
    self.title = endpoint.name
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(DetailLabelCell.self, forCellReuseIdentifier: "DetailLabelCell")
    tableView.register(DestructiveCell.self, forCellReuseIdentifier: "DestructiveCell")
  }
}

// MARK: - UITableViewDataSource

extension EndpointDetailsViewController {
  public override func numberOfSections(in tableView: UITableView) -> Int {
    3
  }

  public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1: return "Stubs"
    case 2: return "Generic stubs"
    default: return nil
    }
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return customizedStubs.count
    case 2: return genericStubs.count
    default: fatalError("Invalid section \(section)")
    }
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let stub: Stub?

    switch indexPath.section {
    case 0:
      stub = nil
    case 1:
      stub = customizedStubs[indexPath.row]
    case 2:
      stub = genericStubs[indexPath.row]
    default:
      fatalError("Invalid section \(indexPath.section)")
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailLabelCell") as! DetailLabelCell

    if let stub = stub {
      cell.textLabel?.text = stub.name
      cell.detailTextLabel?.text = stub.statusCode.map { String($0) }
      cell.isSelected = stubber.activeStub(forEndpointNamed: endpoint.name) == stub
      cell.accessoryType = stubber.activeStub(forEndpointNamed: endpoint.name) == stub ? .checkmark : .none
    } else {
      cell.textLabel?.text = "No stubbing"
      cell.accessoryType = stubber.activeStub(forEndpointNamed: endpoint.name) == nil ? .checkmark : .none
    }

    return cell
  }
}

// MARK: - UITableViewDelegate

extension EndpointDetailsViewController {
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      stubber.activate(stub: nil, forEndpointNamed: endpoint.name)
    case 1:
      let stub = customizedStubs[indexPath.row]
      stubber.activate(stub: stub, forEndpointNamed: endpoint.name)
    case 2:
      let stub = genericStubs[indexPath.row]
      stubber.activate(stub: stub, forEndpointNamed: endpoint.name)
    default:
      fatalError("Invalid section \(indexPath.section)")
    }

    navigationController?.popViewController(animated: true)
  }
}

#endif
