import SpeltKit
//import Commandant

print("Hello CLI!!!")

let fixturesPath = "~/Projects/Spelt/framework/SpeltTests/Fixtures".stringByExpandingTildeInPath
let sampleProjectPath = fixturesPath.stringByAppendingPathComponent("test-site")

let site = try SiteReader(sitePath: sampleProjectPath).read()

//print("building site: \(site)")
