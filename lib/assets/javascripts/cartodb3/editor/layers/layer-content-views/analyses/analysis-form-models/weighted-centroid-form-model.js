var _ = require('underscore');
var BaseAnalysisFormModel = require('./base-analysis-form-model');
var template = require('./weighted-centroid-form.tpl');
var ColumnOptions = require('../column-options');

/**
 * Form model for a weighted-centroid analysis
 * It has a rather complicated schema, that depends on several data points and state.
 */
module.exports = BaseAnalysisFormModel.extend({
  initialize: function () {
    BaseAnalysisFormModel.prototype.initialize.apply(this, arguments);
    this.on('change:aggregate', this._onUpdateAggregate, this);

    this._columnOptions = new ColumnOptions({}, {
      configModel: this._configModel,
      nodeDefModel: this._layerDefinitionModel.findAnalysisDefinitionNodeModel(this.get('source'))
    });

    this.listenTo(this._columnOptions, 'columnsFetched', this._setSchema);

    this._setSchema();
  },

  getTemplate: function () {
    return template;
  },

  /*
  /**
   * @override {BaseAnalysisFormModel._setSchema}
   */
  _setSchema: function () {
    var schema = {
      source: {
        type: 'Select',
        text: _t('editor.layers.analysis-form.source'),
        options: [ this.get('source') ],
        editorAttrs: { disabled: true }
      },
      category_column: {
        type: 'Select',
        title: _t('editor.layers.analysis-form.category-column'),
        options: this._columnOptions.all()
      },
      weight_column: {
        type: 'Select',
        title: _t('editor.layers.analysis-form.weight-column'),
        options: this._columnOptions.filterByType('number')
      },
      aggregate: {
        type: 'Enabler',
        title: _t('editor.layers.analysis-form.aggregate')
      }
    };

    if (this.get('aggregate')) {
      schema = _.extend(schema, {
        aggregate_column: {
          type: 'Select',
          title: _t('editor.layers.analysis-form.column'),
          options: this._columnOptions.filterByType('number')
        },
        aggregate_operation: {
          type: 'Select',
          title: _t('editor.layers.analysis-form.operation'),
          options: [
            { label: _t('editor.layers.aggregate-functions.sum'), val: 'sum' },
            { label: _t('editor.layers.aggregate-functions.avg'), val: 'avg' },
            { label: _t('editor.layers.aggregate-functions.min'), val: 'min' },
            { label: _t('editor.layers.aggregate-functions.max'), val: 'max' }
          ],
          validators: ['required']
        }
      });
    }
    BaseAnalysisFormModel.prototype._setSchema.call(this, schema);
  },

  _onUpdateAggregate: function () {
    if (!this.get('aggregate')) {
      this.unset('aggregate_column', { silent: true });
      this.set('aggregate_operation', 'count');
    } else {
      this.unset('aggregate_operation');
    }
    this._setSchema();
  }
});