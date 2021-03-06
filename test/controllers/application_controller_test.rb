class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'an endpoint should return a 401 error when a user does not have access to the editor' do 
    # Arrange
    ENV['GOOGLE_CLIENT_ID'] = 'client-id'
    GoogleIDToken::Validator.any_instance.expects(:check).with('auth token', 'client-id').returns({ 'email' => 'auth@gmail.com' })
    Editors.expects(:find_by_email).returns([])

    # Act
    get '/editors', headers: { 'Authorization': 'Bearer auth token' }
    json = JSON.parse(response.body)

    # Assert
    assert_response :unauthorized
    assert_equal 'The associated Google Account does not have access to the editor', json['error']
    assert_not json['isAuthorized']
  end

  test 'an endpoint should return a 401 error when a users google oauth token is invalid' do 
    # Arrange
    ENV['GOOGLE_CLIENT_ID'] = 'client-id'
    GoogleIDToken::Validator.any_instance.expects(:check).with('auth token', 'client-id').raises(GoogleIDToken::ValidationError)

    # Act
    get '/editors', headers: { 'Authorization': 'Bearer auth token' }
    json = JSON.parse(response.body)

    # Assert
    assert_response :unauthorized
    assert_equal 'Invalid Google oauth token', json['error']
    assert_not json['isAuthorized']
  end

  test 'an endpoint should return a 500 error when the API throws an error' do 
    # Arrange
    ENV['GOOGLE_CLIENT_ID'] = 'client-id'
    GoogleIDToken::Validator.any_instance.expects(:check).with('auth token', 'client-id').raises(RuntimeError, 'My Message')

    # Act
    get '/editors', headers: { 'Authorization': 'Bearer auth token' }
    json = JSON.parse(response.body)

    # Assert
    assert_response :internal_server_error
    assert_equal 'My Message', json['error']
  end

  test 'an endpoint should return a 500 error when Airrecord throws an error' do 
    # Arrange
    ENV['GOOGLE_CLIENT_ID'] = 'client-id'
    GoogleIDToken::Validator.any_instance.expects(:check).with('auth token', 'client-id').returns({ 'email' => 'auth@gmail.com' })
    Editors.expects(:find_by_email).raises(Airrecord::Error, 'My Message')

    # Act
    get '/editors', headers: { 'Authorization': 'Bearer auth token' }
    json = JSON.parse(response.body)

    # Assert
    assert_response :internal_server_error
    assert_equal 'My Message', json['error']
  end
end
