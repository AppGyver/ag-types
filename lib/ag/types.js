(function() {
  var Failure, Success, assertFunction, getType, isArray, isObject, listSequence, map, mapValues, nativeTypeValidator, object, objectSequence, objectWithProperty, pairs, pairsToObject, types, _ref, _ref1;

  _ref = require('lodash'), pairs = _ref.pairs, object = _ref.object, map = _ref.map, mapValues = _ref.mapValues;

  _ref1 = require('data.validation'), Success = _ref1.Success, Failure = _ref1.Failure;

  objectSequence = function(nameValidationPairs) {
    var failures, name, result, validation;
    failures = [];
    result = (function() {
      var _i, _len, _ref2, _results;
      _results = [];
      for (_i = 0, _len = nameValidationPairs.length; _i < _len; _i++) {
        _ref2 = nameValidationPairs[_i], name = _ref2[0], validation = _ref2[1];
        _results.push(validation.fold(function(failure) {
          failures = failures.concat(failure);
          return [name, null];
        }, function(success) {
          return [name, success];
        }));
      }
      return _results;
    })();
    if (failures.length > 0) {
      return Failure(failures);
    } else {
      return Success(pairsToObject(result));
    }
  };

  pairsToObject = function(pairs) {
    var key, result, value, _i, _len, _ref2;
    result = {};
    for (_i = 0, _len = pairs.length; _i < _len; _i++) {
      _ref2 = pairs[_i], key = _ref2[0], value = _ref2[1];
      result[key] = value;
    }
    return result;
  };

  listSequence = function(list) {
    var failures, index, result, validation;
    failures = [];
    result = (function() {
      var _i, _len, _results;
      _results = [];
      for (index = _i = 0, _len = list.length; _i < _len; index = ++_i) {
        validation = list[index];
        _results.push(validation.fold(function(failure) {
          failures = failures.concat(objectWithProperty(index)(failure));
          return null;
        }, function(success) {
          return success;
        }));
      }
      return _results;
    })();
    if (failures.length > 0) {
      return Failure(failures);
    } else {
      return Success(result);
    }
  };

  objectWithProperty = function(name) {
    return function(value) {
      object = {};
      object[name] = value;
      return object;
    };
  };

  getType = function(input) {
    return Object.prototype.toString.call(input).match(/\[object ([^\]]+)\]/)[1].toLowerCase();
  };

  isArray = function(input) {
    return (Object.prototype.toString.call(input)) === '[object Array]';
  };

  isObject = function(input) {
    return (Object.prototype.toString.call(input)) === '[object Object]';
  };

  nativeTypeValidator = function(expectedType) {
    return function(input) {
      var actualType;
      actualType = getType(input);
      if (expectedType === actualType) {
        return Success(input);
      } else {
        return Failure(["Input was of type " + actualType + " instead of " + expectedType]);
      }
    };
  };

  assertFunction = function(input) {
    if (typeof input !== 'function') {
      throw new Error("Type constructor argument was of type '" + (getType(input)) + "', function expected");
    }
  };

  module.exports = types = {
    Any: function(input) {
      if (input != null) {
        return Success(input);
      } else {
        return Failure(["Input was undefined"]);
      }
    },
    OneOf: function(types) {
      var type, _i, _len;
      for (_i = 0, _len = types.length; _i < _len; _i++) {
        type = types[_i];
        assertFunction(type);
      }
      return function(input) {
        var fail, validation, _j, _len1;
        fail = Failure([]);
        for (_j = 0, _len1 = types.length; _j < _len1; _j++) {
          type = types[_j];
          validation = type(input);
          if (validation.isSuccess) {
            return validation;
          } else {
            fail = fail.ap(validation);
          }
        }
        return fail;
      };
    },
    String: nativeTypeValidator('string'),
    Boolean: nativeTypeValidator('boolean'),
    Number: nativeTypeValidator('number'),
    Property: function(name, type) {
      if (type == null) {
        type = types.Any;
      }
      assertFunction(type);
      return function(object) {
        return ((object != null ? object[name] : void 0) != null ? type(object[name]) : type(null)).leftMap(function(errors) {
          var result;
          result = {};
          result[name] = errors;
          return result;
        });
      };
    },
    Object: function(memberTypes) {
      var propertyNamesToTypes;
      propertyNamesToTypes = mapValues(memberTypes, function(type, name) {
        assertFunction(type);
        return types.Property(name, type);
      });
      return function(object) {
        return objectSequence(pairs(mapValues(propertyNamesToTypes, function(propertyType) {
          return propertyType(object);
        })));
      };
    },
    List: function(type) {
      assertFunction(type);
      return function(input) {
        var value;
        if (!isArray(input)) {
          return Failure(["Input was of type " + (getType(input)) + " instead of array"]);
        } else {
          return listSequence((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = input.length; _i < _len; _i++) {
              value = input[_i];
              _results.push(type(value));
            }
            return _results;
          })());
        }
      };
    },
    Map: function(type) {
      assertFunction(type);
      return function(input) {
        if (!isObject(input)) {
          return Failure(["Input was of type " + (getType(input)) + " instead of object"]);
        } else {
          return objectSequence(pairs(mapValues(input, function(_, propertyName) {
            return types.Property(propertyName, type)(input);
          })));
        }
      };
    },
    Optional: function(type) {
      assertFunction(type);
      return function(input) {
        if (input != null) {
          return type(input);
        } else {
          return Success(null);
        }
      };
    },
    projections: {
      Property: function(name, type) {
        if (type == null) {
          type = types.Any;
        }
        assertFunction(type);
        return function(value) {
          return type(value).map(objectWithProperty(name));
        };
      }
    },
    recursive: function(typeProvider) {
      var type;
      type = null;
      return function(input) {
        if (type == null) {
          type = typeProvider();
          assertFunction(type);
        }
        return type(input);
      };
    }
  };

}).call(this);
