let transform = {};

transform.MainContext = function(children) {
    return 'abc';
};

transform.MajorBlockContext = function(children) {
    children.map(process_node);
};

let process_node = function(node) {
    let label = node.constructor.name;
    return transform[label].call(null, node.children);
};

module.exports = process_node;
