# Copyright 2013 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


require 'digest'

module Importer
  # @abstract
  module NtBase

    @@implementations = []
    def NtBase.included(klass)
      @@implementations << klass
    end
    def NtBase.implementations
      @@implementations
    end

    # @private
    def add_nt_string(string, comment, options={})
      key = key_for(string, comment)
      key = @blob.project.keys.for_key(key).source_copy_matches(string).create_or_update!(
          options.reverse_merge(
              key:                  key,
              source_copy:          string,
              context:              comment,
              importer:             self.class.ident,
              fencers:              self.class.fencers,
              skip_readiness_hooks: true)
      )
      @keys << key

      key.translations.in_locale(@blob.project.base_locale).create_or_update!(
          source_copy:              string,
          copy:                     string,
          approved:                 true,
          source_rfc5646_locale:    @blob.project.base_rfc5646_locale,
          rfc5646_locale:           @blob.project.base_rfc5646_locale,
          skip_readiness_hooks:     true,
          preserve_reviewed_status: true)
    end

    def key_for(string, comment)
      "#{string} (#{comment})"
    end
  end
end
