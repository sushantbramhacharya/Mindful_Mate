import { useEffect, useState } from "react";

function MusicManager() {
  const [musicList, setMusicList] = useState([]);
  const [filteredMusic, setFilteredMusic] = useState([]);
  const [file, setFile] = useState(null);
  const [musicName, setMusicName] = useState("");
  const [author, setAuthor] = useState("");
  const [category, setCategory] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState("All");
  
  // For edit
  const [editingMusicId, setEditingMusicId] = useState(null);
  const [editMusicName, setEditMusicName] = useState("");
  const [editAuthor, setEditAuthor] = useState("");
  const [editCategory, setEditCategory] = useState("");

  const API_URL = "http://localhost:5000";

  const fetchMusic = async () => {
    try {
      const res = await fetch(`${API_URL}/music`);
      const data = await res.json();
      setMusicList(data);
      setFilteredMusic(data);
    } catch (err) {
      console.error("Failed to fetch music list", err);
    }
  };

  useEffect(() => {
    fetchMusic();
  }, []);

  useEffect(() => {
    if (selectedCategory === "All") {
      setFilteredMusic(musicList);
    } else {
      setFilteredMusic(
        musicList.filter((m) => m.category.toLowerCase() === selectedCategory.toLowerCase())
      );
    }
  }, [selectedCategory, musicList]);

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!file || !musicName || !author || !category) {
      alert("All fields are required.");
      return;
    }

    setLoading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("musicName", musicName);
    formData.append("author", author);
    formData.append("category", category);

    try {
      const res = await fetch(`${API_URL}/upload-music`, {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      alert(data.message || data.error);
      setMusicName("");
      setAuthor("");
      setCategory("");
      setFile(null);
      fetchMusic();
    } catch (err) {
      console.error("Upload error", err);
      alert("Upload failed");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    const confirmDelete = window.confirm("Are you sure you want to delete?");
    if (!confirmDelete) return;

    try {
      const res = await fetch(`${API_URL}/music/${id}`, { method: "DELETE" });
      const data = await res.json();
      alert(data.message || data.error);
      fetchMusic();
    } catch (err) {
      console.error("Delete error", err);
      alert("Failed to delete music");
    }
  };

  // Start editing: populate edit fields and set editingMusicId
  const startEdit = (music) => {
    setEditingMusicId(music._id);
    setEditMusicName(music.music_name);
    setEditAuthor(music.author);
    setEditCategory(music.category);
  };

  // Cancel editing
  const cancelEdit = () => {
    setEditingMusicId(null);
    setEditMusicName("");
    setEditAuthor("");
    setEditCategory("");
  };

  // Save edited music info
  const saveEdit = async (id) => {
    if (!editMusicName || !editAuthor || !editCategory) {
      alert("All fields are required to update.");
      return;
    }

    try {
      const res = await fetch(`${API_URL}/music/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          musicName: editMusicName,
          author: editAuthor,
          category: editCategory,
        }),
      });

      const data = await res.json();
      if (res.ok) {
        alert(data.message || "Music updated successfully");
        fetchMusic();
        cancelEdit();
      } else {
        alert(data.error || "Failed to update music");
      }
    } catch (err) {
      console.error("Edit error", err);
      alert("Failed to update music");
    }
  };

  const categories = ["All", ...new Set(musicList.map((m) => m.category))];

  return (
    <div className="max-w-3xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6 text-center">🎵 Music Manager</h1>

      {/* Upload Form */}
      <form
        onSubmit={handleUpload}
        className="bg-white shadow rounded-lg p-4 mb-6 space-y-4"
      >
        <div>
          <label className="block text-sm font-semibold mb-1">Music File</label>
          <input
            type="file"
            accept="audio/*"
            onChange={(e) => setFile(e.target.files[0])}
            required
            className="block w-full"
          />
        </div>
        <div>
          <input
            type="text"
            placeholder="Music Name"
            value={musicName}
            onChange={(e) => setMusicName(e.target.value)}
            required
            className="w-full border p-2 rounded"
          />
        </div>
        <div>
          <input
            type="text"
            placeholder="Author"
            value={author}
            onChange={(e) => setAuthor(e.target.value)}
            required
            className="w-full border p-2 rounded"
          />
        </div>
        <div>
          <input
            type="text"
            placeholder="Category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            required
            className="w-full border p-2 rounded"
          />
        </div>
        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          {loading ? "Uploading..." : "Upload Music"}
        </button>
      </form>

      {/* Category Filter */}
      <div className="mb-4">
        <label className="font-semibold mr-2">Filter by Category:</label>
        <select
          value={selectedCategory}
          onChange={(e) => setSelectedCategory(e.target.value)}
          className="border rounded p-1"
        >
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      {/* Music List */}
      <h2 className="text-xl font-semibold mb-4">🎶 Uploaded Music</h2>
      {filteredMusic.length === 0 ? (
        <p className="text-center text-gray-500">No music found.</p>
      ) : (
        <ul className="space-y-4">
          {filteredMusic.map((music) => {
            const filename = music.file_path?.split("/").pop();
            const audioSrc = `http://localhost:5000/uploads/${filename}`;

            // If this music is in edit mode, show inputs instead of text
            const isEditing = editingMusicId === music._id;

            return (
              <li
                key={music._id}
                className="bg-gray-100 p-4 rounded shadow flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4"
              >
                <div className="flex-grow">
                  {isEditing ? (
                    <>
                      <input
                        type="text"
                        value={editMusicName}
                        onChange={(e) => setEditMusicName(e.target.value)}
                        className="mb-1 w-full border rounded p-1"
                      />
                      <input
                        type="text"
                        value={editAuthor}
                        onChange={(e) => setEditAuthor(e.target.value)}
                        className="mb-1 w-full border rounded p-1"
                      />
                      <input
                        type="text"
                        value={editCategory}
                        onChange={(e) => setEditCategory(e.target.value)}
                        className="mb-1 w-full border rounded p-1"
                      />
                      <audio controls className="mt-2 w-full">
                        <source src={audioSrc} type="audio/mpeg" />
                        Your browser does not support the audio tag.
                      </audio>
                    </>
                  ) : (
                    <>
                      <p className="font-bold">{music.music_name}</p>
                      <p className="text-sm text-gray-600">
                        {music.author} | {music.category}
                      </p>
                      <audio controls className="mt-2 w-full">
                        <source src={audioSrc} type="audio/mpeg" />
                        Your browser does not support the audio tag.
                      </audio>
                    </>
                  )}
                </div>

                <div className="flex gap-2">
                  {isEditing ? (
                    <>
                      <button
                        onClick={() => saveEdit(music._id)}
                        className="bg-green-600 text-white px-4 py-1 rounded hover:bg-green-700"
                      >
                        Save
                      </button>
                      <button
                        onClick={cancelEdit}
                        className="bg-gray-400 text-white px-4 py-1 rounded hover:bg-gray-500"
                      >
                        Cancel
                      </button>
                    </>
                  ) : (
                    <>
                      <button
                        onClick={() => startEdit(music)}
                        className="bg-yellow-500 text-white px-4 py-1 rounded hover:bg-yellow-600"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(music._id)}
                        className="bg-red-500 text-white px-4 py-1 rounded hover:bg-red-600"
                      >
                        Delete
                      </button>
                    </>
                  )}
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}

export default MusicManager;
