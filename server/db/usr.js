const getUser = (username, email) => ({
    $or: [
        { username: username },
        { email: email }
    ]
});

module.exports = {getUser};