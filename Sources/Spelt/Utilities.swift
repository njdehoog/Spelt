/**
* Extend + operator to be able to merge two dictionaries of the same type
*/
func +<T, U>(left: [T: U], right: [T: U]) -> Dictionary<T,U> {
    var combined = left
    for (k, v) in right {
        combined.updateValue(v, forKey: k)
    }
    return combined
}
