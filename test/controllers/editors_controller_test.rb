require_relative './base_controller_test'

class EditorsControllerTest < BaseControllerTest
  test 'index should return all editors with a 200 status code from the Airtable database 
        sorted by name when the request is valid' do 
    editor1 = nil
    editor2 = nil
    editor3 = nil

    begin
      # Arrange
      editor1 = Editors.create('Name': 'test2', 'Email': 'test2@gmail.com')
      editor2 = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')
      editor3 = Editors.create('Name': 'test3', 'Email': 'test3@gmail.com')

      # Act
      get '/editors', headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :success

      assert_equal 3, json.length
      assert_editor('test1', 'test1@gmail.com', json[0])
      assert_editor('test2', 'test2@gmail.com', json[1])
      assert_editor('test3', 'test3@gmail.com', json[2])
    ensure
      editor1.destroy if editor1
      editor2.destroy if editor2
      editor3.destroy if editor3
    end
  end

  test 'create should return the new editor with a 200 status code when given valid parameters' do 
    # Act
    new_editor_id = nil

    begin
      post '/editors', params: { name: 'test', email: 'test@gmail.com' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)
      new_editor_id = json['id']

      # Assert
      assert_response :success
      assert_editor('test', 'test@gmail.com', json)
    ensure
      Editors.find(new_editor_id).destroy if new_editor_id
    end
  end

  test 'create should return an error message with a 400 status code when given an email of an existing edtior' do 
    editor = nil

    begin
      # Arrange
      editor = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')

      # Act
      post '/editors', params: { name: 'test', email: 'test1@gmail.com' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :bad_request
      assert_equal 'An editor already exists with the email test1@gmail.com', json['error']
    ensure
      editor.destroy if editor
    end
  end

  test 'create should return an error message with a 400 status code when not given a name' do 
    # Act
    post '/editors', params: { email: 'test@gmail.com' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
    json = JSON.parse(response.body)

    # Assert
    assert_response :bad_request
    assert_equal 'A name is required to create an editor.', json['error']
  end

  test 'create should return an error message with a 400 status code when not given an email' do 
    # Act
    post '/editors', params: { name: 'test' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
    json = JSON.parse(response.body)

    # Assert
    assert_response :bad_request
    assert_equal 'A email is required to create an editor.', json['error']
  end

  test 'create should return an error message with a 400 status code when not given a name or an email' do 
    # Act
    post '/editors', headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
    json = JSON.parse(response.body)

    # Assert
    assert_response :bad_request
    assert_equal 'A name and an email is required to create an editor.', json['error']
  end

  test 'edit should return the updated editor with a 200 status code when provided a new name and email' do 
    editor = nil

    begin
      # Arrange
      editor = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')

      # Act
      put '/editors', params: { id: editor.id, name: 'test', email: 'test@gmail.com' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :success
      assert_editor('test', 'test@gmail.com', json)
    ensure
      editor.destroy if editor
    end
  end

  test 'edit should return the updated editor with a 200 status code when provided a new name and not an email' do 
    editor = nil

    begin
      # Arrange
      editor = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')

      # Act
      put '/editors', params: { id: editor.id, name: 'test' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :success
      assert_editor('test', 'test1@gmail.com', json)
    ensure
      editor.destroy if editor
    end
  end

  test 'edit should return the updated editor with a 200 status code when provided a new email and not a name' do 
    editor = nil

    begin
      # Arrange
      editor = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')

      # Act
      put '/editors', params: { id: editor.id, email: 'test@gmail.com' }, headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :success
      assert_editor('test1', 'test@gmail.com', json)
    ensure
      editor.destroy if editor
    end
  end

  test 'delete should return a 200 ok response with a successful delete indication when provided valid parameters' do 
    editor = nil
    editor_deleted = false

    begin
      # Arrange
      editor = Editors.create('Name': 'test1', 'Email': 'test1@gmail.com')
      
      # Act
      delete "/editors?id=#{editor.id}", headers: { 'Authorization': "Bearer #{AUTH_TOKEN}" }
      json = JSON.parse(response.body)

      # Assert
      assert_response :success
      assert json['success']
      editor_deleted = true
    ensure
      editor.destroy if editor && !editor_deleted
    end
  end

  private
    def assert_editor(name, email, actual)
      assert_equal name, actual['fields']['Name']
      assert_equal email, actual['fields']['Email']
    end
end
