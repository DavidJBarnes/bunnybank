class TestAuth:
    async def test_register(self, client):
        response = await client.post(
            "/api/v1/auth/register",
            json={
                "name": "New Parent",
                "email": "new@test.com",
                "password": "secret123",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert "access_token" in data
        assert data["parent"]["email"] == "new@test.com"

    async def test_register_duplicate_email(self, client, parent):
        response = await client.post(
            "/api/v1/auth/register",
            json={
                "name": "Dup",
                "email": "parent@test.com",
                "password": "secret123",
            },
        )
        assert response.status_code == 409

    async def test_login(self, client, parent):
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "parent@test.com",
                "password": "password123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data

    async def test_login_wrong_password(self, client, parent):
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "parent@test.com",
                "password": "wrongpass",
            },
        )
        assert response.status_code == 401


class TestChildren:
    async def test_list_children(self, client, parent_token, child):
        response = await client.get(
            "/api/v1/children",
            headers={"Authorization": f"Bearer {parent_token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        assert data[0]["name"] == "Test Child"

    async def test_create_child(self, client, parent_token):
        response = await client.post(
            "/api/v1/children",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={
                "name": "New Kid",
                "age": 6,
                "birthday": "2020-03-10",
                "pin": "5678",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "New Kid"
        assert data["age"] == 6

    async def test_update_child_pin(self, client, parent_token, child):
        response = await client.put(
            f"/api/v1/children/{child.id}/pin",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={"pin": "9999"},
        )
        assert response.status_code == 200

    async def test_delete_child(self, client, parent_token, child):
        response = await client.delete(
            f"/api/v1/children/{child.id}",
            headers={"Authorization": f"Bearer {parent_token}"},
        )
        assert response.status_code == 204


class TestReasons:
    async def test_list_reasons(self, client, parent_token, reason):
        response = await client.get(
            "/api/v1/reasons",
            headers={"Authorization": f"Bearer {parent_token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1

    async def test_create_reason(self, client, parent_token):
        response = await client.post(
            "/api/v1/reasons",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={"label": "bonus"},
        )
        assert response.status_code == 201
        assert response.json()["label"] == "bonus"

    async def test_delete_reason(self, client, parent_token, reason):
        response = await client.delete(
            f"/api/v1/reasons/{reason.id}",
            headers={"Authorization": f"Bearer {parent_token}"},
        )
        assert response.status_code == 204


class TestSendMoney:
    async def test_send_money(self, client, parent_token, child, reason):
        response = await client.post(
            "/api/v1/send-money",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={
                "child_ids": [str(child.id)],
                "amount": 5.0,
                "reason_id": str(reason.id),
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert data["transactions_count"] == 1

    async def test_send_money_invalid_child(self, client, parent_token, reason):
        response = await client.post(
            "/api/v1/send-money",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={
                "child_ids": ["00000000-0000-0000-0000-000000000000"],
                "amount": 5.0,
                "reason_id": str(reason.id),
            },
        )
        assert response.status_code == 400

    async def test_send_money_negative_amount(
        self, client, parent_token, child, reason
    ):
        response = await client.post(
            "/api/v1/send-money",
            headers={"Authorization": f"Bearer {parent_token}"},
            json={
                "child_ids": [str(child.id)],
                "amount": -5.0,
                "reason_id": str(reason.id),
            },
        )
        assert response.status_code == 400


class TestChildAuth:
    async def test_child_login(self, client, child):
        response = await client.post(
            "/api/v1/child/login",
            json={
                "child_id": str(child.id),
                "pin": "1234",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["child_name"] == "Test Child"

    async def test_child_login_wrong_pin(self, client, child):
        response = await client.post(
            "/api/v1/child/login",
            json={
                "child_id": str(child.id),
                "pin": "0000",
            },
        )
        assert response.status_code == 401

    async def test_child_balance(self, client, child_token):
        response = await client.get(
            "/api/v1/child/balance",
            headers={"Authorization": f"Bearer {child_token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "balance" in data

    async def test_child_transactions(self, client, child_token):
        response = await client.get(
            "/api/v1/child/transactions",
            headers={"Authorization": f"Bearer {child_token}"},
        )
        assert response.status_code == 200
        assert isinstance(response.json(), list)
