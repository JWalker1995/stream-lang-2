let transformers = {};

import AstBlock = require('./ast/block');

let node_types = {
    'block': AstBlock,
};

class AstBuilder {
    private calls: Array<Function>;
    constructor(private init_func: Function) {
    }

    static create(node_type_key) {
        return new AstBuilder(function(node) {
            return new node_types[node_type_key]();
        });
    }
    static use(key) {
        return new AstBuilder(function(node) {
            return AstBuilder.resolve_child(node, key);
        });
    }
    static empty() {
        return new AstBuilder(function(node) {});
    }

    static arg_node() {
        return {
            '_map_node': true,
        };
    }
    static arg_child(key) {
        return {
            '_map_child': true,
            'key': key,
        };
    }

    static resolve_child(node, key) {
        if (typeof key === 'string') {
            return node[key]();
        } else if (typeof key === 'number') {
            return node.children[key];
        } else {
            throw new Error('Unexpected resolve_child key type ' + (typeof key));
        }
    }

    call(method, ...args) {
        this._calls.push(function(obj, node) {
            args.map(function(arg) {
                if (arg._map_node === true) {
                    return node;
                } else if (arg._map_child === true) {
                    return AstBuilder.resolve_child(node, arg.key);
                } else {
                    return arg;
                }
            })
            obj[method].call(obj, args);
        });
        return this;
    }

    build(node) {
        let obj = this._init_func.call(null, node);
        this._calls.forEach(function(func) {
            func.call(null, obj, node);
        });
        return obj;
    }
}

transformers.MainBodyContext = AstBuilder
    .use('body')
    ;
transformers.MajorBlockContext = AstBuilder
    .use('body')
    .call('set_implicit_out', false)
    ;
transformers.MinorBlockContext = AstBuilder
    .use('body')
    .call('set_implicit_out', true)
    ;
transformers.ImmediateBlockContext = AstBuilder
    .use('body')
    .call('set_implicit_out', true)
    .call('set_immediate', true)
    ;
transformers.CreateBlockContext = AstBuilder
    .create('block')
    .call('append_statement', AstBuilder.arg_child('statement'))
    ;
transformers.AddBlockContext = AstBuilder
    .use('body')
    .call('append_statement', AstBuilder.arg_child('statement'))
    ;
transformers.AssignmentStatementContext = AstBuilder
    .create('statement')
    .call('set_dst', AstBuilder.arg_child('lValue'))
    .call('set_src', AstBuilder.arg_child('rValue'))
    ;
transformers.ExpressionStatementContext = AstBuilder
    .use('rValue')
    ;
transformers.EmptyStatementContext = AstBuilder
    .empty()
    ;
transformers.ImplicitLValueContext = AstBuilder
    .create('lvalue')
    ;

AstBuilder.transform(transformers);

thing.ImplicitLValueContext = {

}


let process_node = function(node) {
    let label = node.constructor.name;
    let trans = transformers[label];
    if (!(trans instanceof AstBuilder)) {
        throw new Error('Transform ' + label + ' not implemented');
    }

    return trans.build(node);
};

module.exports = process_node;
