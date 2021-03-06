# frozen_string_literal: true

module NpmDataSanitizer
  def self.repository_url(url)
    return nil if url.nil?
    sanitized_url = url.dup
    if sanitized_url.match?(%r{^http:///})
      sanitized_url.sub!('http:///', 'http://')
    end
    if sanitized_url.match?(/git@github.com/)
      sanitized_url.sub!('git@github.com', 'github.com')
    end
    if sanitized_url.match?(%r{^git\+https://})
      sanitized_url.sub!(/^git\+/, '')
    elsif sanitized_url.match?(%r{^git\+ssh://github.com})
      sanitized_url.sub!(/^git\+ssh/, 'https')
    elsif sanitized_url.match?(%r{^github.com[:/]})
      sanitized_url.sub!(%r{^github.com[:/]}, 'https://github.com/')
    elsif sanitized_url.match?(%r{^git://})
      sanitized_url.sub!(%r{^git://}, 'https://')
    end
    sanitized_url.sub!(%r{/$}, '')
    sanitized_url.sub!(/\.git$/, '')
    sanitized_url.sub(/`$/, '')
  end
end
